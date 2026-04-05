use airform_core::{Manifest, ManifestNode, Materialization, TestDef, UniqueId};
use airform_graph::DbtGraph;
use datafusion::prelude::*;
use std::path::Path;
use std::time::{Duration, Instant};

/// Quote a SQL identifier to prevent injection via model/column names.
/// Doubles any internal double-quotes, then wraps in double-quotes.
fn quote_ident(ident: &str) -> String {
    format!("\"{}\"", ident.replace('"', "\"\""))
}

/// Executes compiled SQL against a DataFusion context (local execution).
pub struct Executor {
    ctx: SessionContext,
}

impl Executor {
    pub fn new() -> Self {
        Self {
            ctx: SessionContext::new(),
        }
    }

    /// Get a reference to the underlying DataFusion session context.
    pub fn session_context(&self) -> &SessionContext {
        &self.ctx
    }

    /// Register all seed CSV files as tables in the DataFusion context.
    /// This must be called BEFORE execute() so that models can reference seeds.
    pub async fn load_seeds(&self, manifest: &Manifest) -> anyhow::Result<Vec<NodeResult>> {
        let mut results = Vec::new();

        for (_id, node) in &manifest.nodes {
            if let ManifestNode::Seed(seed) = node {
                let start = Instant::now();
                let table_name = &seed.name;
                let csv_path = &seed.path;

                if !csv_path.exists() {
                    results.push(NodeResult {
                        unique_id: seed.unique_id.clone(),
                        name: seed.name.clone(),
                        status: NodeStatus::Error,
                        duration: start.elapsed(),
                        rows_affected: None,
                        message: Some(format!("CSV file not found: {}", csv_path.display())),
                    });
                    continue;
                }

                match self.register_csv(table_name, csv_path).await {
                    Ok(row_count) => {
                        tracing::info!("Loaded seed: {table_name} ({row_count} rows)");
                        results.push(NodeResult {
                            unique_id: seed.unique_id.clone(),
                            name: seed.name.clone(),
                            status: NodeStatus::Success,
                            duration: start.elapsed(),
                            rows_affected: Some(row_count),
                            message: None,
                        });
                    }
                    Err(e) => {
                        results.push(NodeResult {
                            unique_id: seed.unique_id.clone(),
                            name: seed.name.clone(),
                            status: NodeStatus::Error,
                            duration: start.elapsed(),
                            rows_affected: None,
                            message: Some(e.to_string()),
                        });
                    }
                }
            }
        }

        Ok(results)
    }

    /// Register a CSV file as a table in DataFusion.
    async fn register_csv(&self, table_name: &str, csv_path: &Path) -> anyhow::Result<usize> {
        let options = CsvReadOptions::new()
            .has_header(true);

        self.ctx
            .register_csv(table_name, csv_path.to_str().unwrap_or_default(), options)
            .await?;

        // Count rows
        let df = self.ctx.sql(&format!("SELECT count(*) as cnt FROM {}", quote_ident(table_name))).await?;
        let batches = df.collect().await?;
        let row_count = if let Some(batch) = batches.first() {
            if batch.num_rows() > 0 {
                let array = batch.column(0);
                let count_array = array
                    .as_any()
                    .downcast_ref::<datafusion::arrow::array::Int64Array>();
                count_array.map(|a| a.value(0) as usize).unwrap_or(0)
            } else {
                0
            }
        } else {
            0
        };

        Ok(row_count)
    }

    /// Execute all compiled models in topological order.
    pub async fn execute(
        &self,
        manifest: &Manifest,
        graph: &DbtGraph,
        selected: Option<&[UniqueId]>,
    ) -> anyhow::Result<ExecutionResult> {
        let order = graph.topological_sort()?;
        let mut results = Vec::new();

        for unique_id in &order {
            // Skip sources
            if manifest.sources.contains_key(unique_id) {
                continue;
            }

            // If selection provided, skip non-selected nodes
            if let Some(selected) = selected {
                if !selected.contains(unique_id) {
                    continue;
                }
            }

            let Some(node) = manifest.nodes.get(unique_id) else {
                continue;
            };

            match node {
                ManifestNode::Model(model) => {
                    // Skip ephemeral models (they're CTEs, not executed directly)
                    if model.config.materialized == Materialization::Ephemeral {
                        results.push(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Skipped,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("ephemeral (CTE only)".to_string()),
                        });
                        continue;
                    }

                    let Some(compiled_sql) = &model.compiled_sql else {
                        results.push(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Error,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("No compiled SQL".to_string()),
                        });
                        continue;
                    };

                    // For incremental models, check if the target table exists.
                    // If not, use the full-refresh SQL variant (compiled with is_incremental()=false)
                    // to avoid referencing {{ this }} which doesn't exist yet.
                    let effective_sql = if model.config.materialized == Materialization::Incremental {
                        let table_name = model.config.alias.as_deref().unwrap_or(&model.name);
                        let table_exists = self.ctx.table(table_name).await.is_ok();
                        if !table_exists {
                            if let Some(fr_sql) = &model.compiled_sql_full_refresh {
                                fr_sql.clone()
                            } else {
                                compiled_sql.clone()
                            }
                        } else {
                            compiled_sql.clone()
                        }
                    } else {
                        compiled_sql.clone()
                    };

                    let start = Instant::now();
                    let result = self.execute_model(
                        &model.name,
                        &effective_sql,
                        &model.config.materialized,
                        model.config.alias.as_deref(),
                        model.config.schema.as_deref(),
                        model.config.unique_key.as_deref(),
                        model.config.incremental_strategy.as_deref(),
                    ).await;

                    match result {
                        Ok(rows) => {
                            results.push(NodeResult {
                                unique_id: unique_id.clone(),
                                name: model.name.clone(),
                                status: NodeStatus::Success,
                                duration: start.elapsed(),
                                rows_affected: Some(rows),
                                message: None,
                            });
                        }
                        Err(e) => {
                            results.push(NodeResult {
                                unique_id: unique_id.clone(),
                                name: model.name.clone(),
                                status: NodeStatus::Error,
                                duration: start.elapsed(),
                                rows_affected: None,
                                message: Some(e.to_string()),
                            });
                        }
                    }
                }
                ManifestNode::Snapshot(snapshot) => {
                    let Some(compiled_sql) = &snapshot.compiled_sql else {
                        results.push(NodeResult {
                            unique_id: unique_id.clone(),
                            name: snapshot.name.clone(),
                            status: NodeStatus::Error,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("No compiled SQL".to_string()),
                        });
                        continue;
                    };

                    let start = Instant::now();
                    let result = self.execute_snapshot(
                        &snapshot.name,
                        compiled_sql,
                        snapshot.config.alias.as_deref(),
                        snapshot.config.unique_key.as_deref(),
                        snapshot.config.strategy.as_deref(),
                        snapshot.config.updated_at.as_deref(),
                        snapshot.config.check_cols.as_deref(),
                    ).await;

                    match result {
                        Ok(rows) => {
                            results.push(NodeResult {
                                unique_id: unique_id.clone(),
                                name: snapshot.name.clone(),
                                status: NodeStatus::Success,
                                duration: start.elapsed(),
                                rows_affected: Some(rows),
                                message: None,
                            });
                        }
                        Err(e) => {
                            results.push(NodeResult {
                                unique_id: unique_id.clone(),
                                name: snapshot.name.clone(),
                                status: NodeStatus::Error,
                                duration: start.elapsed(),
                                rows_affected: None,
                                message: Some(e.to_string()),
                            });
                        }
                    }
                }
                _ => {}
            }
        }

        Ok(ExecutionResult { results })
    }

    /// Execute a single model's SQL against DataFusion.
    async fn execute_model(
        &self,
        name: &str,
        sql: &str,
        materialization: &Materialization,
        alias: Option<&str>,
        _schema: Option<&str>,
        unique_key: Option<&str>,
        incremental_strategy: Option<&str>,
    ) -> anyhow::Result<usize> {
        let table_name = alias.unwrap_or(name);

        match materialization {
            Materialization::View => {
                // Register as a view
                let df = self.ctx.sql(sql).await?;
                self.ctx
                    .register_table(table_name, df.into_view())?;
                tracing::info!("Created view: {table_name}");
                Ok(0)
            }
            Materialization::Table => {
                // Execute and register result as a table
                let df = self.ctx.sql(sql).await?;
                let batches = df.collect().await?;
                let row_count: usize = batches.iter().map(|b| b.num_rows()).sum();

                // Create a memory table from the results
                if !batches.is_empty() {
                    let schema = batches[0].schema();
                    let table =
                        datafusion::datasource::MemTable::try_new(schema, vec![batches])?;
                    // Deregister if exists, then register
                    let _ = self.ctx.deregister_table(table_name);
                    self.ctx.register_table(table_name, std::sync::Arc::new(table))?;
                }
                tracing::info!("Created table: {table_name} ({row_count} rows)");
                Ok(row_count)
            }
            Materialization::Incremental => {
                // Execute the new SQL to get new batches
                let df = self.ctx.sql(sql).await?;
                let new_batches = df.collect().await?;

                if new_batches.is_empty() {
                    tracing::info!("Created incremental table: {table_name} (0 rows, no data)");
                    return Ok(0);
                }

                let new_schema = new_batches[0].schema();

                // Determine strategy: explicit > default based on unique_key
                let strategy = incremental_strategy.unwrap_or(
                    if unique_key.is_some() { "delete+insert" } else { "append" }
                );

                // Check if the old table exists
                let old_table_exists = self.ctx.table(table_name).await.is_ok();

                let final_batches = if old_table_exists {
                    match strategy {
                        "append" => {
                            // Read old rows, concatenate with new
                            let old_df = self.ctx.table(table_name).await?;
                            let old_batches = old_df.collect().await?;
                            let mut combined = old_batches;
                            combined.extend(new_batches);
                            combined
                        }
                        "delete+insert" | "merge" => {
                            if let Some(key) = unique_key {
                                // Register new batches as a temp table
                                let temp_name = format!("__new_{table_name}");
                                let temp_table = datafusion::datasource::MemTable::try_new(
                                    new_schema.clone(),
                                    vec![new_batches.clone()],
                                )?;
                                let _ = self.ctx.deregister_table(temp_name.as_str());
                                self.ctx.register_table(
                                    temp_name.as_str(),
                                    std::sync::Arc::new(temp_table),
                                )?;

                                // Filter old rows: keep only those whose key is NOT in new data
                                let qk = quote_ident(key);
                                let qt = quote_ident(table_name);
                                let qtemp = quote_ident(&temp_name);
                                let filter_sql = format!(
                                    "SELECT * FROM {qt} WHERE {qk} NOT IN (SELECT {qk} FROM {qtemp})"
                                );
                                let filtered_df = self.ctx.sql(&filter_sql).await?;
                                let filtered_old = filtered_df.collect().await?;

                                // Clean up temp table
                                let _ = self.ctx.deregister_table(temp_name.as_str());

                                // Concatenate filtered old + new
                                let mut combined = filtered_old;
                                combined.extend(new_batches);
                                combined
                            } else {
                                // No unique_key with delete+insert/merge: fall back to append
                                let old_df = self.ctx.table(table_name).await?;
                                let old_batches = old_df.collect().await?;
                                let mut combined = old_batches;
                                combined.extend(new_batches);
                                combined
                            }
                        }
                        _ => {
                            tracing::warn!(
                                "Unknown incremental strategy '{strategy}', falling back to append"
                            );
                            let old_df = self.ctx.table(table_name).await?;
                            let old_batches = old_df.collect().await?;
                            let mut combined = old_batches;
                            combined.extend(new_batches);
                            combined
                        }
                    }
                } else {
                    // No old table, just use new batches
                    new_batches
                };

                let row_count: usize = final_batches.iter().map(|b| b.num_rows()).sum();

                if !final_batches.is_empty() {
                    let schema = final_batches[0].schema();
                    let table = datafusion::datasource::MemTable::try_new(
                        schema,
                        vec![final_batches],
                    )?;
                    let _ = self.ctx.deregister_table(table_name);
                    self.ctx
                        .register_table(table_name, std::sync::Arc::new(table))?;
                }
                tracing::info!(
                    "Created incremental table: {table_name} ({row_count} rows, strategy={strategy})"
                );
                Ok(row_count)
            }
            Materialization::Ephemeral => {
                // Ephemeral models are never executed directly
                Ok(0)
            }
        }
    }

    /// Execute a snapshot with SCD Type 2 logic.
    async fn execute_snapshot(
        &self,
        name: &str,
        sql: &str,
        alias: Option<&str>,
        unique_key: Option<&str>,
        strategy: Option<&str>,
        updated_at: Option<&str>,
        check_cols: Option<&[String]>,
    ) -> anyhow::Result<usize> {
        let table_name = alias.unwrap_or(name);
        let strategy = strategy.unwrap_or("timestamp");

        let unique_key = unique_key.ok_or_else(|| {
            anyhow::anyhow!("Snapshot '{name}' requires a unique_key config")
        })?;
        let quk = quote_ident(unique_key);
        let qtable = quote_ident(table_name);

        // Step 1: Execute the snapshot query and register as temp table
        let temp_name = format!("__snap_new_{table_name}");
        let df = self.ctx.sql(sql).await?;
        let new_batches = df.collect().await?;

        if new_batches.is_empty() {
            tracing::info!("Snapshot {table_name}: query returned no rows");
            return Ok(0);
        }

        let new_schema = new_batches[0].schema();
        let temp_table = datafusion::datasource::MemTable::try_new(
            new_schema.clone(),
            vec![new_batches],
        )?;
        let _ = self.ctx.deregister_table(temp_name.as_str());
        self.ctx.register_table(
            temp_name.as_str(),
            std::sync::Arc::new(temp_table),
        )?;

        // Step 2: Check if target snapshot table already exists
        let table_exists = self.ctx.table(table_name).await.is_ok();

        let final_batches = if !table_exists {
            // First run: add SCD columns to new data and register
            let col_names: Vec<String> = new_schema
                .fields()
                .iter()
                .map(|f| f.name().clone())
                .collect();
            let col_list = col_names.join(", ");

            let qtemp = quote_ident(&temp_name);
            let init_sql = format!(
                "SELECT {col_list}, \
                 CURRENT_TIMESTAMP AS dbt_valid_from, \
                 CAST(NULL AS TIMESTAMP) AS dbt_valid_to, \
                 CURRENT_TIMESTAMP AS dbt_updated_at, \
                 MD5(CAST({quk} AS VARCHAR) || CAST(CURRENT_TIMESTAMP AS VARCHAR)) AS dbt_scd_id \
                 FROM {qtemp}"
            );

            let df = self.ctx.sql(&init_sql).await?;
            let batches = df.collect().await?;
            tracing::info!("Snapshot {table_name}: initial load");
            batches
        } else {
            // Subsequent run: SCD Type 2 merge logic
            let qtemp = quote_ident(&temp_name);
            let change_condition = match strategy {
                "timestamp" => {
                    let updated_at_col = updated_at.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{name}' with timestamp strategy requires updated_at config"
                        )
                    })?;
                    let qua = quote_ident(updated_at_col);
                    format!("old_snap.{qua} != new_snap.{qua}")
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{name}' with check strategy requires check_cols config"
                        )
                    })?;
                    if cols.is_empty() {
                        anyhow::bail!("Snapshot '{name}': check_cols must not be empty");
                    }
                    cols.iter()
                        .map(|c| { let qc = quote_ident(c); format!("old_snap.{qc} != new_snap.{qc}") })
                        .collect::<Vec<_>>()
                        .join(" OR ")
                }
                other => {
                    anyhow::bail!("Unknown snapshot strategy: '{other}'. Use 'timestamp' or 'check'.");
                }
            };

            // Get column names from existing snapshot (excluding SCD columns)
            let existing_df = self.ctx.table(table_name).await?;
            let existing_schema = existing_df.schema();
            let scd_columns = ["dbt_valid_from", "dbt_valid_to", "dbt_updated_at", "dbt_scd_id"];
            let source_cols: Vec<String> = existing_schema
                .fields()
                .iter()
                .map(|f| f.name().clone())
                .filter(|n| !scd_columns.contains(&n.as_str()))
                .collect();

            let old_source_cols = source_cols
                .iter()
                .map(|c| { let qc = quote_ident(c); format!("old_snap.{qc}") })
                .collect::<Vec<_>>()
                .join(", ");
            let new_source_cols = source_cols
                .iter()
                .map(|c| { let qc = quote_ident(c); format!("new_snap.{qc}") })
                .collect::<Vec<_>>()
                .join(", ");

            // Query 1: Unchanged active records + already-expired records
            let unchanged_sql = format!(
                "SELECT old_snap.* FROM {qtable} old_snap \
                 LEFT JOIN {qtemp} new_snap ON old_snap.{quk} = new_snap.{quk} \
                 WHERE old_snap.dbt_valid_to IS NOT NULL \
                 OR new_snap.{quk} IS NULL \
                 OR (old_snap.dbt_valid_to IS NULL AND NOT ({change_condition}))"
            );

            // Query 2: Expire active records that have changed
            let expire_sql = format!(
                "SELECT {old_source_cols}, \
                 old_snap.dbt_valid_from, \
                 CURRENT_TIMESTAMP AS dbt_valid_to, \
                 CURRENT_TIMESTAMP AS dbt_updated_at, \
                 old_snap.dbt_scd_id \
                 FROM {qtable} old_snap \
                 JOIN {qtemp} new_snap ON old_snap.{quk} = new_snap.{quk} \
                 WHERE old_snap.dbt_valid_to IS NULL AND ({change_condition})"
            );

            // Query 3: Insert new versions of changed records + entirely new records
            let insert_sql = format!(
                "SELECT {new_source_cols}, \
                 CURRENT_TIMESTAMP AS dbt_valid_from, \
                 CAST(NULL AS TIMESTAMP) AS dbt_valid_to, \
                 CURRENT_TIMESTAMP AS dbt_updated_at, \
                 MD5(CAST(new_snap.{quk} AS VARCHAR) || CAST(CURRENT_TIMESTAMP AS VARCHAR)) AS dbt_scd_id \
                 FROM {qtemp} new_snap \
                 LEFT JOIN {qtable} old_snap ON old_snap.{quk} = new_snap.{quk} AND old_snap.dbt_valid_to IS NULL \
                 WHERE old_snap.{quk} IS NULL OR ({change_condition})"
            );

            let merge_sql = format!(
                "{unchanged_sql} UNION ALL {expire_sql} UNION ALL {insert_sql}"
            );

            let df = self.ctx.sql(&merge_sql).await?;
            let batches = df.collect().await?;
            tracing::info!("Snapshot {table_name}: SCD Type 2 merge (strategy={strategy})");
            batches
        };

        // Clean up temp table
        let _ = self.ctx.deregister_table(format!("__snap_new_{table_name}").as_str());

        let row_count: usize = final_batches.iter().map(|b| b.num_rows()).sum();

        if !final_batches.is_empty() {
            let schema = final_batches[0].schema();
            let table = datafusion::datasource::MemTable::try_new(
                schema,
                vec![final_batches],
            )?;
            let _ = self.ctx.deregister_table(table_name);
            self.ctx.register_table(table_name, std::sync::Arc::new(table))?;
        }

        tracing::info!("Snapshot table: {table_name} ({row_count} rows)");
        Ok(row_count)
    }

    /// Execute an ad-hoc SQL query against the current session context.
    pub async fn execute_query(&self, sql: &str) -> anyhow::Result<Vec<datafusion::arrow::record_batch::RecordBatch>> {
        let df = self.ctx.sql(sql).await?;
        let batches = df.collect().await?;
        Ok(batches)
    }

    /// Execute generic tests defined in schema.yml and return test results.
    pub async fn execute_tests(&self, manifest: &Manifest) -> anyhow::Result<Vec<TestResult>> {
        let mut results = Vec::new();

        for (_id, node) in &manifest.nodes {
            let (model_name, columns) = match node {
                ManifestNode::Model(m) => (&m.name, &m.columns),
                _ => continue,
            };

            for col in columns {
                for test_def in &col.tests {
                    let (test_name, test_sql) = match test_def {
                        TestDef::Simple(name) => {
                            let qm = quote_ident(model_name);
                            let qc = quote_ident(&col.name);
                            match name.as_str() {
                                "not_null" => (
                                    format!("not_null_{model_name}_{}", col.name),
                                    format!(
                                        "SELECT count(*) as failures FROM {qm} WHERE {qc} IS NULL"
                                    ),
                                ),
                                "unique" => (
                                    format!("unique_{model_name}_{}", col.name),
                                    format!(
                                        "SELECT {qc}, count(*) as n FROM {qm} GROUP BY {qc} HAVING count(*) > 1"
                                    ),
                                ),
                                _ => continue,
                            }
                        }
                        TestDef::Complex(map) => {
                            let qm = quote_ident(model_name);
                            let qc = quote_ident(&col.name);
                            if let Some(values_val) = map.get("accepted_values") {
                                let values = extract_accepted_values(values_val);
                                if values.is_empty() {
                                    continue;
                                }
                                let values_list = values
                                    .iter()
                                    .map(|v| format!("'{}'", v.replace('\'', "''")))
                                    .collect::<Vec<_>>()
                                    .join(", ");
                                (
                                    format!("accepted_values_{model_name}_{}", col.name),
                                    format!(
                                        "SELECT {qc} FROM {qm} WHERE {qc} NOT IN ({values_list})"
                                    ),
                                )
                            } else if let Some(rel_val) = map.get("relationships") {
                                let (to_model, field) = extract_relationship(rel_val);
                                if to_model.is_empty() || field.is_empty() {
                                    continue;
                                }
                                let qt = quote_ident(&to_model);
                                let qf = quote_ident(&field);
                                (
                                    format!("relationships_{model_name}_{}", col.name),
                                    format!(
                                        "SELECT {qc} FROM {qm} WHERE {qc} IS NOT NULL AND {qc} NOT IN (SELECT {qf} FROM {qt})"
                                    ),
                                )
                            } else {
                                continue;
                            }
                        }
                    };

                    let start = Instant::now();
                    match self.run_test_sql(&test_sql).await {
                        Ok(failure_count) => {
                            let status = if failure_count == 0 {
                                TestStatus::Pass
                            } else {
                                TestStatus::Fail
                            };
                            results.push(TestResult {
                                test_name,
                                model_name: model_name.clone(),
                                column_name: col.name.clone(),
                                status,
                                failures: failure_count,
                                duration: start.elapsed(),
                                message: None,
                            });
                        }
                        Err(e) => {
                            results.push(TestResult {
                                test_name,
                                model_name: model_name.clone(),
                                column_name: col.name.clone(),
                                status: TestStatus::Error,
                                failures: 0,
                                duration: start.elapsed(),
                                message: Some(e.to_string()),
                            });
                        }
                    }
                }
            }
        }

        Ok(results)
    }

    /// Run a test SQL query and return the number of failing rows.
    async fn run_test_sql(&self, sql: &str) -> anyhow::Result<usize> {
        let df = self.ctx.sql(sql).await?;
        let batches = df.collect().await?;

        // For not_null tests, the query returns count(*) as failures
        // For unique/accepted_values/relationships tests, it returns the failing rows
        if batches.is_empty() {
            return Ok(0);
        }

        // Check if the result has a "failures" column (not_null style)
        let schema = batches[0].schema();
        if schema.fields().len() == 1 && schema.field(0).name() == "failures" {
            // not_null style: single count
            let array = batches[0].column(0);
            if let Some(int_array) = array.as_any().downcast_ref::<datafusion::arrow::array::Int64Array>() {
                return Ok(int_array.value(0) as usize);
            }
        }

        // Otherwise, count all returned rows as failures
        let row_count: usize = batches.iter().map(|b| b.num_rows()).sum();
        Ok(row_count)
    }
}

/// Extract accepted_values list from a serde_yaml::Value
fn extract_accepted_values(val: &serde_yaml::Value) -> Vec<String> {
    if let Some(mapping) = val.as_mapping() {
        let key = serde_yaml::Value::String("values".to_string());
        if let Some(values) = mapping.get(&key) {
            if let Some(seq) = values.as_sequence() {
                return seq
                    .iter()
                    .filter_map(|v| v.as_str().map(String::from))
                    .collect();
            }
        }
    }
    Vec::new()
}

/// Extract relationship target model and field from a serde_yaml::Value
fn extract_relationship(val: &serde_yaml::Value) -> (String, String) {
    if let Some(mapping) = val.as_mapping() {
        let to_key = serde_yaml::Value::String("to".to_string());
        let field_key = serde_yaml::Value::String("field".to_string());

        let to_model = mapping
            .get(&to_key)
            .and_then(|v| v.as_str())
            .unwrap_or_default();
        let field = mapping
            .get(&field_key)
            .and_then(|v| v.as_str())
            .unwrap_or_default();

        // Parse ref('model_name') -> model_name
        let to_model = to_model
            .trim()
            .strip_prefix("ref('")
            .and_then(|s| s.strip_suffix("')"))
            .or_else(|| {
                to_model
                    .trim()
                    .strip_prefix("ref(\"")
                    .and_then(|s| s.strip_suffix("\")"))
            })
            .unwrap_or(to_model);

        return (to_model.to_string(), field.to_string());
    }
    (String::new(), String::new())
}

impl Default for Executor {
    fn default() -> Self {
        Self::new()
    }
}

/// Result of executing all models
#[derive(Debug)]
pub struct ExecutionResult {
    pub results: Vec<NodeResult>,
}

impl ExecutionResult {
    pub fn success_count(&self) -> usize {
        self.results
            .iter()
            .filter(|r| r.status == NodeStatus::Success)
            .count()
    }

    pub fn error_count(&self) -> usize {
        self.results
            .iter()
            .filter(|r| r.status == NodeStatus::Error)
            .count()
    }

    pub fn skipped_count(&self) -> usize {
        self.results
            .iter()
            .filter(|r| r.status == NodeStatus::Skipped)
            .count()
    }

    pub fn total_duration(&self) -> Duration {
        self.results.iter().map(|r| r.duration).sum()
    }
}

/// Result of executing a single node
#[derive(Debug)]
pub struct NodeResult {
    pub unique_id: UniqueId,
    pub name: String,
    pub status: NodeStatus,
    pub duration: Duration,
    pub rows_affected: Option<usize>,
    pub message: Option<String>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum NodeStatus {
    Success,
    Error,
    Skipped,
}

impl std::fmt::Display for NodeStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            NodeStatus::Success => write!(f, "SUCCESS"),
            NodeStatus::Error => write!(f, "ERROR"),
            NodeStatus::Skipped => write!(f, "SKIP"),
        }
    }
}

/// Result of running a single test
#[derive(Debug)]
pub struct TestResult {
    pub test_name: String,
    pub model_name: String,
    pub column_name: String,
    pub status: TestStatus,
    pub failures: usize,
    pub duration: Duration,
    pub message: Option<String>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum TestStatus {
    Pass,
    Fail,
    Error,
}

impl std::fmt::Display for TestStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TestStatus::Pass => write!(f, "PASS"),
            TestStatus::Fail => write!(f, "FAIL"),
            TestStatus::Error => write!(f, "ERROR"),
        }
    }
}
