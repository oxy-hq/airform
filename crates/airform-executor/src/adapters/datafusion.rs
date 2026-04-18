use airform_core::{Manifest, Materialization};
use airform_graph::DbtGraph;
use async_trait::async_trait;
use datafusion::prelude::*;
use std::path::{Path, PathBuf};
use std::sync::Arc;

use crate::warehouse::{QueryResult, WarehouseAdapter, qualified_quoted, quote_ident};

/// DataFusion-based local adapter.
///
/// Executes compiled SQL against an in-memory DataFusion context.
/// Applies SQL compatibility rewrites (DATE_DIFF, qualified aliases, etc.)
/// that are needed because DataFusion has a different SQL dialect than
/// real dbt targets.
pub struct DataFusionAdapter {
    ctx: SessionContext,
}

impl DataFusionAdapter {
    pub fn new() -> Self {
        Self {
            ctx: SessionContext::new(),
        }
    }

    /// Get a reference to the underlying DataFusion session context.
    pub fn session_context(&self) -> &SessionContext {
        &self.ctx
    }
}

// ---------------------------------------------------------------------------
// WarehouseAdapter implementation
// ---------------------------------------------------------------------------

#[async_trait]
impl WarehouseAdapter for DataFusionAdapter {
    fn as_any(&self) -> &dyn std::any::Any {
        self
    }

    async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult> {
        let df = self.ctx.sql(sql).await?;
        let batches = df.collect().await?;
        Ok(batches_to_query_result(&batches))
    }

    async fn materialize(
        &self,
        schema: &str,
        table: &str,
        sql: &str,
        materialization: &Materialization,
        unique_key: Option<&str>,
        incremental_strategy: Option<&str>,
    ) -> anyhow::Result<usize> {
        let qualified = format!("{}.{}", schema, table);
        let qualified_q = qualified_quoted(schema, table);

        // Apply DataFusion compatibility fixes
        let sql = &fix_qualified_aliases(sql);
        let sql = &fix_sql_compat(sql);

        self.ensure_schema(schema).await?;

        match materialization {
            Materialization::View => {
                let df = self.ctx.sql(sql).await?;
                self.ctx.register_table(&qualified, df.into_view())?;
                tracing::info!("Created view: {table}");
                Ok(0)
            }
            Materialization::Table => {
                let df = self.ctx.sql(sql).await?;
                let batches = df.collect().await?;
                let row_count: usize = batches.iter().map(|b| b.num_rows()).sum();

                if !batches.is_empty() {
                    let arrow_schema = batches[0].schema();
                    let mem_table =
                        datafusion::datasource::MemTable::try_new(arrow_schema, vec![batches])?;
                    let _ = self.ctx.deregister_table(&qualified);
                    self.ctx
                        .register_table(&qualified, Arc::new(mem_table))?;
                }
                tracing::info!("Created table: {table} ({row_count} rows)");
                Ok(row_count)
            }
            Materialization::Incremental => {
                let df = self.ctx.sql(sql).await?;
                let new_batches = df.collect().await?;

                if new_batches.is_empty() {
                    tracing::info!("Created incremental table: {table} (0 rows, no data)");
                    return Ok(0);
                }

                let new_schema = new_batches[0].schema();
                let strategy = incremental_strategy
                    .unwrap_or(if unique_key.is_some() { "delete+insert" } else { "append" });

                let old_table_exists = self.ctx.table(&qualified).await.is_ok();

                let final_batches = if old_table_exists {
                    match strategy {
                        "append" => {
                            let old_df = self.ctx.table(&qualified).await?;
                            let old_batches = old_df.collect().await?;
                            let mut combined = old_batches;
                            combined.extend(new_batches);
                            combined
                        }
                        "delete+insert" | "merge" => {
                            if let Some(key) = unique_key {
                                let temp_name = format!("__new_{table}");
                                let temp_table = datafusion::datasource::MemTable::try_new(
                                    new_schema.clone(),
                                    vec![new_batches.clone()],
                                )?;
                                let _ = self.ctx.deregister_table(temp_name.as_str());
                                self.ctx.register_table(
                                    temp_name.as_str(),
                                    Arc::new(temp_table),
                                )?;

                                let qk = quote_ident(key);
                                let qtemp = quote_ident(&temp_name);
                                let filter_sql = format!(
                                    "SELECT * FROM {qualified_q} WHERE {qk} NOT IN (SELECT {qk} FROM {qtemp})"
                                );
                                let filtered_df = self.ctx.sql(&filter_sql).await?;
                                let filtered_old = filtered_df.collect().await?;
                                let _ = self.ctx.deregister_table(temp_name.as_str());

                                let mut combined = filtered_old;
                                combined.extend(new_batches);
                                combined
                            } else {
                                let old_df = self.ctx.table(&qualified).await?;
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
                            let old_df = self.ctx.table(&qualified).await?;
                            let old_batches = old_df.collect().await?;
                            let mut combined = old_batches;
                            combined.extend(new_batches);
                            combined
                        }
                    }
                } else {
                    new_batches
                };

                let row_count: usize = final_batches.iter().map(|b| b.num_rows()).sum();

                if !final_batches.is_empty() {
                    let arrow_schema = final_batches[0].schema();
                    let mem_table = datafusion::datasource::MemTable::try_new(
                        arrow_schema,
                        vec![final_batches],
                    )?;
                    let _ = self.ctx.deregister_table(&qualified);
                    self.ctx
                        .register_table(&qualified, Arc::new(mem_table))?;
                }
                tracing::info!(
                    "Created incremental table: {table} ({row_count} rows, strategy={strategy})"
                );
                Ok(row_count)
            }
            Materialization::Ephemeral => Ok(0),
        }
    }

    async fn execute_snapshot(
        &self,
        schema: &str,
        table: &str,
        sql: &str,
        unique_key: &str,
        strategy: &str,
        updated_at: Option<&str>,
        check_cols: Option<&[String]>,
    ) -> anyhow::Result<usize> {
        let qualified = format!("{}.{}", schema, table);
        let qtable = qualified_quoted(schema, table);
        let quk = quote_ident(unique_key);

        self.ensure_schema(schema).await?;

        // Step 1: Execute the snapshot query and register as temp table
        let temp_name = format!("__snap_new_{table}");
        let df = self.ctx.sql(sql).await?;
        let new_batches = df.collect().await?;

        if new_batches.is_empty() {
            tracing::info!("Snapshot {table}: query returned no rows");
            return Ok(0);
        }

        let new_schema = new_batches[0].schema();
        let temp_table = datafusion::datasource::MemTable::try_new(
            new_schema.clone(),
            vec![new_batches],
        )?;
        let _ = self.ctx.deregister_table(temp_name.as_str());
        self.ctx
            .register_table(temp_name.as_str(), Arc::new(temp_table))?;

        // Step 2: Check if target snapshot table already exists
        let table_exists = self.ctx.table(&qualified).await.is_ok();

        let final_batches = if !table_exists {
            // First run: add SCD columns to new data
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
            tracing::info!("Snapshot {table}: initial load");
            batches
        } else {
            // Subsequent run: SCD Type 2 merge logic
            let qtemp = quote_ident(&temp_name);
            let change_condition = match strategy {
                "timestamp" => {
                    let updated_at_col = updated_at.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{table}' with timestamp strategy requires updated_at config"
                        )
                    })?;
                    let qua = quote_ident(updated_at_col);
                    format!("old_snap.{qua} != new_snap.{qua}")
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{table}' with check strategy requires check_cols config"
                        )
                    })?;
                    if cols.is_empty() {
                        anyhow::bail!("Snapshot '{table}': check_cols must not be empty");
                    }
                    cols.iter()
                        .map(|c| {
                            let qc = quote_ident(c);
                            format!("old_snap.{qc} != new_snap.{qc}")
                        })
                        .collect::<Vec<_>>()
                        .join(" OR ")
                }
                other => {
                    anyhow::bail!(
                        "Unknown snapshot strategy: '{other}'. Use 'timestamp' or 'check'."
                    );
                }
            };

            // Get column names from existing snapshot (excluding SCD columns)
            let existing_df = self.ctx.table(&qualified).await?;
            let existing_schema = existing_df.schema();
            let scd_columns =
                ["dbt_valid_from", "dbt_valid_to", "dbt_updated_at", "dbt_scd_id"];
            let source_cols: Vec<String> = existing_schema
                .fields()
                .iter()
                .map(|f| f.name().clone())
                .filter(|n| !scd_columns.contains(&n.as_str()))
                .collect();

            let old_source_cols = source_cols
                .iter()
                .map(|c| {
                    let qc = quote_ident(c);
                    format!("old_snap.{qc}")
                })
                .collect::<Vec<_>>()
                .join(", ");
            let new_source_cols = source_cols
                .iter()
                .map(|c| {
                    let qc = quote_ident(c);
                    format!("new_snap.{qc}")
                })
                .collect::<Vec<_>>()
                .join(", ");

            let unchanged_sql = format!(
                "SELECT old_snap.* FROM {qtable} old_snap \
                 LEFT JOIN {qtemp} new_snap ON old_snap.{quk} = new_snap.{quk} \
                 WHERE old_snap.dbt_valid_to IS NOT NULL \
                 OR new_snap.{quk} IS NULL \
                 OR (old_snap.dbt_valid_to IS NULL AND NOT ({change_condition}))"
            );

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

            let merge_sql =
                format!("{unchanged_sql} UNION ALL {expire_sql} UNION ALL {insert_sql}");

            let df = self.ctx.sql(&merge_sql).await?;
            let batches = df.collect().await?;
            tracing::info!("Snapshot {table}: SCD Type 2 merge (strategy={strategy})");
            batches
        };

        // Clean up temp table
        let _ = self
            .ctx
            .deregister_table(format!("__snap_new_{table}").as_str());

        let row_count: usize = final_batches.iter().map(|b| b.num_rows()).sum();

        if !final_batches.is_empty() {
            let arrow_schema = final_batches[0].schema();
            let mem_table = datafusion::datasource::MemTable::try_new(
                arrow_schema,
                vec![final_batches],
            )?;
            let _ = self.ctx.deregister_table(&qualified);
            self.ctx
                .register_table(&qualified, Arc::new(mem_table))?;
        }

        tracing::info!("Snapshot table: {table} ({row_count} rows)");
        Ok(row_count)
    }

    async fn load_seed(
        &self,
        table_name: &str,
        schema: &str,
        csv_path: &Path,
    ) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;

        let effective_path = normalize_csv_timestamps(csv_path)?;
        let csv_str = effective_path.to_str().unwrap_or_default();

        let options = CsvReadOptions::new()
            .has_header(true)
            .schema_infer_max_records(10000);
        let qualified = format!("{}.{}", schema, table_name);
        self.ctx.register_csv(&qualified, csv_str, options).await?;

        // Lowercase all column names for dbt compatibility
        let qualified_q = qualified_quoted(schema, table_name);
        let df = self
            .ctx
            .sql(&format!("SELECT * FROM {} LIMIT 0", qualified_q))
            .await?;
        let schema_ref = df.schema();
        let has_upper = schema_ref
            .fields()
            .iter()
            .any(|f| f.name() != &f.name().to_lowercase());
        if has_upper {
            let renames: Vec<String> = schema_ref
                .fields()
                .iter()
                .map(|f| {
                    let name = f.name();
                    let lower = name.to_lowercase();
                    if name == &lower {
                        quote_ident(name)
                    } else {
                        format!("{} AS {}", quote_ident(name), quote_ident(&lower))
                    }
                })
                .collect();
            let select_sql = format!("SELECT {} FROM {}", renames.join(", "), qualified_q);
            let lowered_df = self.ctx.sql(&select_sql).await?;
            self.ctx.deregister_table(
                datafusion::common::TableReference::full("datafusion", schema, table_name),
            )?;
            self.ctx.register_table(
                datafusion::common::TableReference::full("datafusion", schema, table_name),
                lowered_df.into_view(),
            )?;
        }

        // Count rows
        let qualified_q = qualified_quoted(schema, table_name);
        let df = self
            .ctx
            .sql(&format!("SELECT count(*) as cnt FROM {}", qualified_q))
            .await?;
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

    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()> {
        let sql = format!("CREATE SCHEMA IF NOT EXISTS {}", quote_ident(schema));
        self.ctx.sql(&sql).await?.collect().await?;
        Ok(())
    }

    async fn table_exists(&self, schema: &str, table: &str) -> anyhow::Result<bool> {
        let qualified = format!("{}.{}", schema, table);
        Ok(self.ctx.table(&qualified).await.is_ok())
    }

    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize> {
        let df = self.ctx.sql(sql).await?;
        let batches = df.collect().await?;

        if batches.is_empty() {
            return Ok(0);
        }

        // Check if the result has a "failures" column (not_null style)
        let schema = batches[0].schema();
        if schema.fields().len() == 1 && schema.field(0).name() == "failures" {
            let array = batches[0].column(0);
            if let Some(int_array) = array
                .as_any()
                .downcast_ref::<datafusion::arrow::array::Int64Array>()
            {
                return Ok(int_array.value(0) as usize);
            }
        }

        // Otherwise, count all returned rows as failures
        let row_count: usize = batches.iter().map(|b| b.num_rows()).sum();
        Ok(row_count)
    }

    async fn register_sources(
        &self,
        manifest: &Manifest,
        _target_schema: &str,
    ) -> anyhow::Result<usize> {
        use datafusion::arrow::datatypes::{DataType, Field, Schema};

        let mut registered = 0;

        let mut to_register: std::collections::HashMap<(String, String), Vec<Field>> =
            std::collections::HashMap::new();

        for source in manifest.sources.values() {
            let table_name = source.table_identifier().to_string();
            let schema_name = source.schema.as_deref().unwrap_or("public").to_string();
            let key = (schema_name.clone(), table_name.clone());

            if to_register.contains_key(&key) {
                continue;
            }

            let fields: Vec<Field> = if source.columns.is_empty() {
                vec![Field::new("_placeholder", DataType::Utf8, true)]
            } else {
                source
                    .columns
                    .iter()
                    .map(|c| {
                        let dt = match c.data_type.as_deref() {
                            Some("string") | Some("text") | Some("varchar") | Some("TEXT") => {
                                DataType::Utf8
                            }
                            Some("integer") | Some("int") | Some("INT") | Some("bigint")
                            | Some("BIGINT") => DataType::Int64,
                            Some("float") | Some("double") | Some("FLOAT") | Some("DOUBLE")
                            | Some("numeric") | Some("NUMERIC") => DataType::Float64,
                            Some("boolean") | Some("bool") | Some("BOOLEAN") => DataType::Boolean,
                            Some("date") | Some("DATE") => DataType::Date32,
                            Some("timestamp") | Some("TIMESTAMP") | Some("datetime") => {
                                DataType::Utf8
                            }
                            _ => DataType::Utf8,
                        };
                        Field::new(&c.name, dt, true)
                    })
                    .collect()
            };

            to_register.insert(key, fields);
        }

        tracing::info!(
            "register_sources: {} unique source tables to register",
            to_register.len()
        );

        for ((schema_name, table_name), fields) in &to_register {
            if let Err(e) = self.ensure_schema(schema_name).await {
                tracing::warn!("ensure_schema({}) failed: {}", schema_name, e);
                continue;
            }

            let arrow_schema = Arc::new(Schema::new(fields.clone()));
            let table_ref = datafusion::common::TableReference::full(
                "datafusion",
                schema_name.as_str(),
                table_name.as_str(),
            );

            let empty_table = match datafusion::datasource::MemTable::try_new(
                arrow_schema,
                vec![vec![]],
            ) {
                Ok(t) => t,
                Err(e) => {
                    tracing::warn!(
                        "MemTable::try_new for {}.{} failed: {}",
                        schema_name,
                        table_name,
                        e
                    );
                    continue;
                }
            };

            match self
                .ctx
                .register_table(table_ref, Arc::new(empty_table))
            {
                Ok(_) => {
                    registered += 1;
                }
                Err(e) => {
                    tracing::debug!(
                        "register_table {}.{}: already exists ({})",
                        schema_name,
                        table_name,
                        e
                    );
                }
            }
        }

        tracing::info!("Registered {} empty source tables", registered);
        Ok(registered)
    }

    async fn register_info_schema(
        &self,
        manifest: &Manifest,
        graph: &DbtGraph,
    ) -> anyhow::Result<()> {
        crate::info_schema::register_info_schema(&self.ctx, manifest, graph)
    }
}

// ---------------------------------------------------------------------------
// DataFusion-specific helpers
// ---------------------------------------------------------------------------

/// Convert DataFusion RecordBatches into an adapter-agnostic QueryResult.
fn batches_to_query_result(
    batches: &[datafusion::arrow::record_batch::RecordBatch],
) -> QueryResult {
    if batches.is_empty() {
        return QueryResult {
            row_count: 0,
            columns: vec![],
            rows: vec![],
        };
    }

    let schema = batches[0].schema();
    let columns: Vec<String> = schema.fields().iter().map(|f| f.name().clone()).collect();

    let mut rows = Vec::new();
    for batch in batches {
        for row_idx in 0..batch.num_rows() {
            let mut row = Vec::with_capacity(batch.num_columns());
            for col_idx in 0..batch.num_columns() {
                let array = batch.column(col_idx);
                row.push(arrow_value_to_json(array.as_ref(), row_idx));
            }
            rows.push(row);
        }
    }

    let row_count = rows.len();
    QueryResult {
        row_count,
        columns,
        rows,
    }
}

fn arrow_value_to_json(
    array: &dyn datafusion::arrow::array::Array,
    row: usize,
) -> serde_json::Value {
    use datafusion::arrow::array::*;
    use datafusion::arrow::datatypes::DataType;

    if array.is_null(row) {
        return serde_json::Value::Null;
    }

    match array.data_type() {
        DataType::Int8 => serde_json::json!(array
            .as_any()
            .downcast_ref::<Int8Array>()
            .unwrap()
            .value(row)),
        DataType::Int16 => serde_json::json!(array
            .as_any()
            .downcast_ref::<Int16Array>()
            .unwrap()
            .value(row)),
        DataType::Int32 => serde_json::json!(array
            .as_any()
            .downcast_ref::<Int32Array>()
            .unwrap()
            .value(row)),
        DataType::Int64 => serde_json::json!(array
            .as_any()
            .downcast_ref::<Int64Array>()
            .unwrap()
            .value(row)),
        DataType::UInt8 => serde_json::json!(array
            .as_any()
            .downcast_ref::<UInt8Array>()
            .unwrap()
            .value(row)),
        DataType::UInt16 => serde_json::json!(array
            .as_any()
            .downcast_ref::<UInt16Array>()
            .unwrap()
            .value(row)),
        DataType::UInt32 => serde_json::json!(array
            .as_any()
            .downcast_ref::<UInt32Array>()
            .unwrap()
            .value(row)),
        DataType::UInt64 => serde_json::json!(array
            .as_any()
            .downcast_ref::<UInt64Array>()
            .unwrap()
            .value(row)),
        DataType::Float32 => serde_json::json!(array
            .as_any()
            .downcast_ref::<Float32Array>()
            .unwrap()
            .value(row)),
        DataType::Float64 => serde_json::json!(array
            .as_any()
            .downcast_ref::<Float64Array>()
            .unwrap()
            .value(row)),
        DataType::Boolean => serde_json::json!(array
            .as_any()
            .downcast_ref::<BooleanArray>()
            .unwrap()
            .value(row)),
        DataType::Utf8 => serde_json::json!(array
            .as_any()
            .downcast_ref::<StringArray>()
            .unwrap()
            .value(row)),
        _ => {
            // Fallback: use arrow's display format
            let formatter =
                datafusion::arrow::util::display::ArrayFormatter::try_new(array, &Default::default());
            match formatter {
                Ok(f) => serde_json::json!(f.value(row).to_string()),
                Err(_) => serde_json::Value::Null,
            }
        }
    }
}

// ---------------------------------------------------------------------------
// DataFusion SQL compatibility fixes
// ---------------------------------------------------------------------------

/// Normalize timestamps in a CSV file to handle non-standard formats.
/// Returns the original path if no changes needed, or a temp file path.
/// Fixes: single-digit hours like "2016-06-25 0:54:37" -> "2016-06-25 00:54:37"
fn normalize_csv_timestamps(csv_path: &Path) -> anyhow::Result<PathBuf> {
    let content = std::fs::read_to_string(csv_path)?;

    let needs_fix = content.contains(" 0:")
        || content.contains(" 1:")
        || content.contains(" 2:")
        || content.contains(" 3:")
        || content.contains(" 4:")
        || content.contains(" 5:")
        || content.contains(" 6:")
        || content.contains(" 7:")
        || content.contains(" 8:")
        || content.contains(" 9:");

    if !needs_fix {
        return Ok(csv_path.to_path_buf());
    }

    let mut fixed = String::with_capacity(content.len() + 256);
    let chars: Vec<char> = content.chars().collect();
    let mut i = 0;
    while i < chars.len() {
        if i + 18 < chars.len()
            && chars[i].is_ascii_digit()
            && chars[i + 1].is_ascii_digit()
            && chars[i + 2].is_ascii_digit()
            && chars[i + 3].is_ascii_digit()
            && chars[i + 4] == '-'
            && chars[i + 5].is_ascii_digit()
            && chars[i + 6].is_ascii_digit()
            && chars[i + 7] == '-'
            && chars[i + 8].is_ascii_digit()
            && chars[i + 9].is_ascii_digit()
            && chars[i + 10] == ' '
            && chars[i + 11].is_ascii_digit()
            && chars[i + 12] == ':'
        {
            for j in 0..11 {
                fixed.push(chars[i + j]);
            }
            fixed.push('0');
            fixed.push(chars[i + 11]);
            i += 12;
            continue;
        }
        fixed.push(chars[i]);
        i += 1;
    }

    let file_name = csv_path
        .file_name()
        .unwrap_or_default()
        .to_string_lossy();
    let temp_path = std::env::temp_dir().join(format!("airform_normalized_{}", file_name));
    std::fs::write(&temp_path, &fixed)?;
    Ok(temp_path)
}

/// Fix DataFusion compatibility issue: when a table is aliased, the original
/// qualified name cannot be used as a column qualifier.
fn fix_qualified_aliases(sql: &str) -> String {
    use std::collections::HashMap;

    let sql_lower = sql.to_lowercase();
    let mut replacements: HashMap<String, String> = HashMap::new();

    let from_re_patterns = [" from ", "\nfrom ", "\rfrom ", "\tfrom "];
    for from_pat in from_re_patterns {
        let mut search_pos = 0;
        while let Some(from_pos) = sql_lower[search_pos..].find(from_pat) {
            let abs_from = search_pos + from_pos + from_pat.len();
            let rest = &sql[abs_from..];
            let rest_trimmed = rest.trim_start();
            let mut end = 0;
            let chars: Vec<char> = rest_trimmed.chars().collect();
            while end < chars.len()
                && (chars[end].is_alphanumeric() || chars[end] == '_' || chars[end] == '.')
            {
                end += 1;
            }
            let qualified = &rest_trimmed[..end];
            if !qualified.contains('.') {
                search_pos = abs_from;
                continue;
            }

            let after_qual = rest_trimmed[end..].trim_start();
            let alias = if after_qual.to_lowercase().starts_with("as ") {
                let after_as = after_qual[3..].trim_start();
                let alias_end = after_as
                    .find(|c: char| !c.is_alphanumeric() && c != '_')
                    .unwrap_or(after_as.len());
                &after_as[..alias_end]
            } else {
                let alias_end = after_qual
                    .find(|c: char| !c.is_alphanumeric() && c != '_')
                    .unwrap_or(after_qual.len());
                let potential = &after_qual[..alias_end];
                let keywords = [
                    "where", "join", "left", "right", "inner", "outer", "cross", "on", "group",
                    "order", "having", "limit", "union", "except", "intersect", "", "select",
                    "from",
                ];
                if keywords.contains(&potential.to_lowercase().as_str()) {
                    search_pos = abs_from;
                    continue;
                }
                potential
            };

            if !alias.is_empty() && alias.len() < 100 {
                replacements.insert(qualified.to_string(), alias.to_string());
            }
            search_pos = abs_from;
        }
    }

    if replacements.is_empty() {
        return sql.to_string();
    }

    let mut result = sql.to_string();
    let mut sorted: Vec<_> = replacements.iter().collect();
    sorted.sort_by(|a, b| b.0.len().cmp(&a.0.len()));

    for (qualified, alias) in sorted {
        let from_pattern = format!("{qualified}.");
        let alias_pattern = format!("{alias}.");
        result = result.replace(&from_pattern, &alias_pattern);
    }

    result
}

/// Fix various DataFusion SQL compatibility issues.
fn fix_sql_compat(sql: &str) -> String {
    let mut result = sql.to_string();

    // Replace DATE_DIFF('part', start, end) with DataFusion-compatible expression.
    loop {
        let lower = result.to_lowercase();
        let Some(pos) = lower.find("date_diff(") else {
            break;
        };
        let start = pos + "date_diff(".len();
        let bytes = result.as_bytes();
        let mut depth = 1;
        let mut i = start;
        while i < bytes.len() && depth > 0 {
            if bytes[i] == b'(' {
                depth += 1;
            } else if bytes[i] == b')' {
                depth -= 1;
            }
            if depth > 0 {
                i += 1;
            }
        }
        if depth != 0 {
            break;
        }
        let args_str = &result[start..i];
        let args = split_top_level(args_str);
        if args.len() == 3 {
            let part = args[0].trim().trim_matches('\'').trim_matches('"');
            let start_expr = args[1].trim();
            let end_expr = args[2].trim();
            let divisor = match part.to_lowercase().as_str() {
                "second" => 1,
                "minute" => 60,
                "hour" => 3600,
                "day" => 86400,
                "week" => 604800,
                _ => 1,
            };
            let replacement = if divisor == 1 {
                format!(
                    "CAST(EXTRACT(EPOCH FROM (CAST({end_expr} AS TIMESTAMP) - CAST({start_expr} AS TIMESTAMP))) AS BIGINT)"
                )
            } else {
                format!(
                    "CAST(EXTRACT(EPOCH FROM (CAST({end_expr} AS TIMESTAMP) - CAST({start_expr} AS TIMESTAMP))) / {divisor} AS BIGINT)"
                )
            };
            result = format!("{}{}{}", &result[..pos], replacement, &result[i + 1..]);
        } else {
            break;
        }
    }

    // Fix DATE_TRUNC with Null-typed second argument
    {
        let lower = result.to_lowercase();
        let mut positions: Vec<usize> = Vec::new();
        let mut offset = 0;
        while let Some(pos) = lower[offset..].find("date_trunc(") {
            positions.push(offset + pos);
            offset += pos + 1;
        }
        for &abs_pos in positions.iter().rev() {
            let start_args = abs_pos + "date_trunc(".len();
            let mut depth = 1;
            let mut comma_pos = None;
            let mut j = start_args;
            let bytes = result.as_bytes();
            while j < bytes.len() && depth > 0 {
                match bytes[j] {
                    b'(' => depth += 1,
                    b')' => {
                        depth -= 1;
                        if depth == 0 {
                            break;
                        }
                    }
                    b',' if depth == 1 && comma_pos.is_none() => comma_pos = Some(j),
                    _ => {}
                }
                j += 1;
            }
            if depth == 0 {
                if let Some(cp) = comma_pos {
                    let date_expr = result[cp + 1..j].trim();
                    if !date_expr.to_lowercase().contains("try_cast")
                        && !date_expr.to_lowercase().contains("cast(")
                    {
                        let new_expr = format!(" TRY_CAST({} AS TIMESTAMP)", date_expr);
                        result = format!("{}{}{}", &result[..cp + 1], new_expr, &result[j..]);
                    }
                }
            }
        }
    }

    // Fix CAST('' AS DATE) and similar
    for pattern in &[
        "cast('' as date)",
        "cast(\"\" as date)",
        "cast('none' as date)",
    ] {
        while let Some(pos) = result.to_lowercase().find(pattern) {
            let end = pos + pattern.len();
            result = format!("{}CAST(NULL AS DATE){}", &result[..pos], &result[end..]);
        }
    }

    // Fix aggregate functions (SUM, AVG) on Null-typed columns
    for agg_fn in &["sum", "avg"] {
        let needle = format!("{agg_fn}(");
        let needle_len = needle.len();
        let lower = result.to_lowercase();
        let mut positions: Vec<usize> = Vec::new();
        let mut offset = 0;
        while let Some(pos) = lower[offset..].find(&needle) {
            let abs = offset + pos;
            if abs > 0 {
                let prev = result.as_bytes()[abs - 1];
                if prev.is_ascii_alphanumeric() || prev == b'_' {
                    offset = abs + 1;
                    continue;
                }
            }
            positions.push(abs);
            offset = abs + 1;
        }
        for &abs_pos in positions.iter().rev() {
            let start_args = abs_pos + needle_len;
            let mut depth = 1;
            let mut j = start_args;
            let bytes = result.as_bytes();
            while j < bytes.len() && depth > 0 {
                match bytes[j] {
                    b'(' => depth += 1,
                    b')' => {
                        depth -= 1;
                        if depth == 0 {
                            break;
                        }
                    }
                    _ => {}
                }
                j += 1;
            }
            if depth == 0 {
                let arg = result[start_args..j].trim();
                let arg_lower = arg.to_lowercase();
                if !arg_lower.contains("try_cast") && !arg_lower.contains("cast(") && arg != "*" {
                    let new_arg = format!("TRY_CAST({} AS DOUBLE)", arg);
                    result = format!("{}{}{}", &result[..start_args], new_arg, &result[j..]);
                }
            }
        }
    }

    // Fix Jinja list rendering: [a, b, c] -> (a, b, c) in SQL IN clauses
    {
        let bytes = result.as_bytes();
        let mut new_result = String::with_capacity(result.len());
        let mut i = 0;
        while i < bytes.len() {
            if bytes[i] == b'[' {
                let prefix = &result[..i].trim_end();
                let lower_prefix = prefix.to_lowercase();
                if lower_prefix.ends_with(" in")
                    || lower_prefix.ends_with("\nin")
                    || lower_prefix.ends_with("\tin")
                {
                    if let Some(close) = result[i..].find(']') {
                        new_result.push('(');
                        new_result.push_str(&result[i + 1..i + close]);
                        new_result.push(')');
                        i += close + 1;
                        continue;
                    }
                }
            }
            new_result.push(bytes[i] as char);
            i += 1;
        }
        result = new_result;
    }

    result
}

/// Split a string on top-level commas (not inside parentheses).
fn split_top_level(s: &str) -> Vec<&str> {
    let mut parts = Vec::new();
    let mut depth = 0;
    let mut start = 0;
    for (i, c) in s.char_indices() {
        match c {
            '(' => depth += 1,
            ')' => depth -= 1,
            ',' if depth == 0 => {
                parts.push(&s[start..i]);
                start = i + 1;
            }
            _ => {}
        }
    }
    parts.push(&s[start..]);
    parts
}
