use airform_core::{DbtTarget, Manifest, ManifestNode, Materialization, TestDef, UniqueId};
use airform_graph::DbtGraph;
use std::time::{Duration, Instant};

use crate::adapter::AdapterType;
use crate::adapters::{self, DataFusionAdapter};
use crate::warehouse::{
    QueryResult, WarehouseAdapter, generate_schema_name, qualified_quoted, quote_ident,
};

/// Executes compiled SQL against a warehouse adapter.
///
/// The Executor handles orchestration: topological ordering, node selection,
/// hook execution, test SQL generation, and result collection. Actual SQL
/// execution is delegated to a `WarehouseAdapter` implementation.
pub struct Executor {
    adapter: Box<dyn WarehouseAdapter>,
    target_schema: String,
}

impl Executor {
    /// Create an Executor with the default DataFusion adapter (backward compat).
    pub fn new(target_schema: &str) -> Self {
        Self {
            adapter: Box::new(DataFusionAdapter::new()),
            target_schema: target_schema.to_string(),
        }
    }

    /// Create an Executor from a DbtTarget, dispatching on adapter_type.
    pub fn from_target(target: &DbtTarget) -> anyhow::Result<Self> {
        let target_schema = target
            .schema
            .clone()
            .unwrap_or_else(|| "public".to_string());
        let adapter_type = AdapterType::from_str(&target.adapter_type);
        let adapter = adapters::create_adapter(&adapter_type, Some(target))?;
        Ok(Self {
            adapter,
            target_schema,
        })
    }

    /// Create an Executor with a specific adapter.
    pub fn with_adapter(adapter: Box<dyn WarehouseAdapter>, target_schema: &str) -> Self {
        Self {
            adapter,
            target_schema: target_schema.to_string(),
        }
    }

    /// Register virtual information schema tables (DataFusion-only, no-op for cloud).
    pub async fn register_info_schema(
        &self,
        manifest: &Manifest,
        graph: &DbtGraph,
    ) -> anyhow::Result<()> {
        self.adapter.register_info_schema(manifest, graph).await
    }

    /// Register all seed CSV files as tables.
    /// Must be called BEFORE execute() so models can reference seeds.
    pub async fn load_seeds(&self, manifest: &Manifest) -> anyhow::Result<Vec<NodeResult>> {
        let mut results = Vec::new();

        // Build a map of source table identifiers to their schemas
        let mut source_schema_map: std::collections::HashMap<String, Vec<String>> =
            std::collections::HashMap::new();
        let mut source_name_to_id: std::collections::HashMap<(String, String), String> =
            std::collections::HashMap::new();
        for source in manifest.sources.values() {
            let table_id = source.table_identifier().to_string();
            let schema = source.schema.as_deref().unwrap_or("public").to_string();
            source_schema_map
                .entry(table_id.clone())
                .or_default()
                .push(schema.clone());
            if source.name != table_id {
                source_name_to_id.insert((schema, source.name.clone()), table_id);
            }
        }

        for (_id, node) in &manifest.nodes {
            if let ManifestNode::Seed(seed) = node {
                let start = Instant::now();
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

                let schema =
                    generate_schema_name(seed.config.schema.as_deref(), &self.target_schema);
                match self.adapter.load_seed(&seed.name, &schema, csv_path).await {
                    Ok(row_count) => {
                        tracing::info!("Loaded seed: {} ({row_count} rows)", seed.name);
                        results.push(NodeResult {
                            unique_id: seed.unique_id.clone(),
                            name: seed.name.clone(),
                            status: NodeStatus::Success,
                            duration: start.elapsed(),
                            rows_affected: Some(row_count),
                            message: None,
                        });

                        // Also register in source schemas if this seed backs a source table
                        if let Some(source_schemas) = source_schema_map.get(&seed.name) {
                            for src_schema in source_schemas {
                                if *src_schema != schema {
                                    match self
                                        .adapter
                                        .load_seed(&seed.name, src_schema, csv_path)
                                        .await
                                    {
                                        Ok(_) => {
                                            tracing::info!(
                                                "Aliased seed {} into source schema {}",
                                                seed.name,
                                                src_schema
                                            );
                                        }
                                        Err(e) => {
                                            tracing::warn!(
                                                "Failed to alias seed {} into source schema {}: {}",
                                                seed.name,
                                                src_schema,
                                                e
                                            );
                                        }
                                    }
                                    // Also register under the source table name if it differs
                                    for ((s, src_name), id) in &source_name_to_id {
                                        if s == src_schema && id == &seed.name {
                                            if let Err(e) = self
                                                .adapter
                                                .load_seed(src_name, src_schema, csv_path)
                                                .await
                                            {
                                                tracing::debug!(
                                                    "Failed to alias seed {} as {} in {}: {}",
                                                    seed.name,
                                                    src_name,
                                                    src_schema,
                                                    e
                                                );
                                            } else {
                                                tracing::info!(
                                                    "Aliased seed {} as {} in {}",
                                                    seed.name,
                                                    src_name,
                                                    src_schema
                                                );
                                            }
                                        }
                                    }
                                }
                            }
                        }
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

        // After loading all seeds, create aliases in model schemas so that
        // unqualified references (e.g., `SELECT * FROM {{ var('connection') }}`)
        // resolve correctly when the model has a custom +schema.
        let seed_base_schema = self.target_schema.clone();
        let seed_names: Vec<String> = manifest.nodes.values()
            .filter_map(|n| match n {
                ManifestNode::Seed(s) => Some(s.name.clone()),
                _ => None,
            })
            .collect();

        // Collect all unique model schemas
        let mut model_schemas: std::collections::HashSet<String> = std::collections::HashSet::new();
        for node in manifest.nodes.values() {
            if let ManifestNode::Model(m) = node {
                let schema = generate_schema_name(m.config.schema.as_deref(), &self.target_schema);
                if schema != seed_base_schema {
                    model_schemas.insert(schema);
                }
            }
        }

        // Create views in model schemas pointing to seed tables
        for schema in &model_schemas {
            self.adapter.ensure_schema(schema).await?;
            for seed_name in &seed_names {
                let qualified_source = format!("{seed_base_schema}.{seed_name}");
                let create_view = format!(
                    "CREATE OR REPLACE VIEW {schema}.{seed_name} AS SELECT * FROM {qualified_source}"
                );
                let _ = self.adapter.execute_query(&create_view).await;
            }
        }

        Ok(results)
    }

    /// Register empty tables for source definitions not backed by seeds.
    pub async fn register_sources(&self, manifest: &Manifest) -> anyhow::Result<usize> {
        self.adapter
            .register_sources(manifest, &self.target_schema)
            .await
    }

    /// Execute a list of hook SQL statements.
    pub async fn execute_hooks(&self, hooks: &[String], context: &str) {
        for hook in hooks {
            let sql = hook.trim();
            if sql.is_empty() {
                continue;
            }
            tracing::info!("{context}: {sql}");
            if let Err(e) = self.adapter.execute_query(sql).await {
                tracing::warn!("{context} failed: {e}");
            }
        }
    }

    /// Execute all compiled models in topological order.
    pub async fn execute(
        &self,
        manifest: &Manifest,
        graph: &DbtGraph,
        selected: Option<&[UniqueId]>,
    ) -> anyhow::Result<ExecutionResult> {
        let (tx, mut rx) = tokio::sync::mpsc::channel(256);
        self.execute_streaming(manifest, graph, selected, tx).await?;
        let mut results = Vec::new();
        while let Some(result) = rx.recv().await {
            results.push(result);
        }
        Ok(ExecutionResult { results })
    }

    /// Streaming variant of [`execute`]: sends each [`NodeResult`] to `tx` as soon as it completes.
    pub async fn execute_streaming(
        &self,
        manifest: &Manifest,
        graph: &DbtGraph,
        selected: Option<&[UniqueId]>,
        tx: tokio::sync::mpsc::Sender<NodeResult>,
    ) -> anyhow::Result<()> {
        let order = graph.topological_sort()?;

        for unique_id in &order {
            if manifest.sources.contains_key(unique_id) {
                continue;
            }
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
                    if model.config.enabled == Some(false) {
                        tx.send(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Skipped,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("disabled".to_string()),
                        }).await?;
                        continue;
                    }

                    if model.config.materialized == Materialization::Ephemeral {
                        tx.send(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Skipped,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("ephemeral (CTE only)".to_string()),
                        }).await?;
                        continue;
                    }

                    let Some(compiled_sql) = &model.compiled_sql else {
                        tx.send(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Error,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("No compiled SQL".to_string()),
                        }).await?;
                        continue;
                    };

                    let sql_trimmed = compiled_sql
                        .lines()
                        .filter(|l| {
                            let t = l.trim();
                            !t.is_empty() && !t.starts_with("--")
                        })
                        .collect::<Vec<_>>()
                        .join("\n");
                    let upper = sql_trimmed.to_uppercase();
                    let has_sql_keyword = upper.contains("SELECT")
                        || upper.contains("INSERT")
                        || upper.contains("CREATE")
                        || upper.contains("WITH")
                        || upper.contains("MERGE");
                    if !has_sql_keyword {
                        tx.send(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Skipped,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("empty SQL (disabled model)".to_string()),
                        }).await?;
                        continue;
                    }

                    let table_name = model.config.alias.as_deref().unwrap_or(&model.name);
                    let schema =
                        generate_schema_name(model.config.schema.as_deref(), &self.target_schema);

                    let effective_sql =
                        if model.config.materialized == Materialization::Incremental {
                            let table_exists = self
                                .adapter
                                .table_exists(&schema, table_name)
                                .await
                                .unwrap_or(false);
                            if !table_exists {
                                model.compiled_sql_full_refresh
                                    .clone()
                                    .unwrap_or_else(|| compiled_sql.clone())
                            } else {
                                compiled_sql.clone()
                            }
                        } else {
                            compiled_sql.clone()
                        };

                    let start = Instant::now();
                    if !model.config.pre_hook.is_empty() {
                        self.execute_hooks(
                            &model.config.pre_hook,
                            &format!("pre-hook({})", model.name),
                        )
                        .await;
                    }
                    let result = self
                        .adapter
                        .materialize(
                            &schema,
                            table_name,
                            &effective_sql,
                            &model.config.materialized,
                            model.config.unique_key.as_deref(),
                            model.config.incremental_strategy.as_deref(),
                        )
                        .await;
                    if !model.config.post_hook.is_empty() {
                        self.execute_hooks(
                            &model.config.post_hook,
                            &format!("post-hook({})", model.name),
                        )
                        .await;
                    }

                    let node_result = match result {
                        Ok(rows) => NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Success,
                            duration: start.elapsed(),
                            rows_affected: Some(rows),
                            message: None,
                        },
                        Err(e) => NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Error,
                            duration: start.elapsed(),
                            rows_affected: None,
                            message: Some(e.to_string()),
                        },
                    };
                    tx.send(node_result).await?;
                }
                ManifestNode::Snapshot(snapshot) => {
                    let Some(compiled_sql) = &snapshot.compiled_sql else {
                        tx.send(NodeResult {
                            unique_id: unique_id.clone(),
                            name: snapshot.name.clone(),
                            status: NodeStatus::Error,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("No compiled SQL".to_string()),
                        }).await?;
                        continue;
                    };

                    let table_name =
                        snapshot.config.alias.as_deref().unwrap_or(&snapshot.name);
                    let schema = generate_schema_name(
                        snapshot.config.schema.as_deref(),
                        &self.target_schema,
                    );
                    let strategy =
                        snapshot.config.strategy.as_deref().unwrap_or("timestamp");

                    let Some(unique_key) = snapshot.config.unique_key.as_deref() else {
                        tx.send(NodeResult {
                            unique_id: unique_id.clone(),
                            name: snapshot.name.clone(),
                            status: NodeStatus::Error,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some(format!(
                                "Snapshot '{}' requires a unique_key config",
                                snapshot.name
                            )),
                        }).await?;
                        continue;
                    };

                    let start = Instant::now();
                    let result = self
                        .adapter
                        .execute_snapshot(
                            &schema,
                            table_name,
                            compiled_sql,
                            unique_key,
                            strategy,
                            snapshot.config.updated_at.as_deref(),
                            snapshot.config.check_cols.as_deref(),
                        )
                        .await;

                    let node_result = match result {
                        Ok(rows) => NodeResult {
                            unique_id: unique_id.clone(),
                            name: snapshot.name.clone(),
                            status: NodeStatus::Success,
                            duration: start.elapsed(),
                            rows_affected: Some(rows),
                            message: None,
                        },
                        Err(e) => NodeResult {
                            unique_id: unique_id.clone(),
                            name: snapshot.name.clone(),
                            status: NodeStatus::Error,
                            duration: start.elapsed(),
                            rows_affected: None,
                            message: Some(e.to_string()),
                        },
                    };
                    tx.send(node_result).await?;
                }
                _ => {}
            }
        }

        Ok(())
    }

    /// Execute an ad-hoc SQL query against the current adapter.
    pub async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult> {
        self.adapter.execute_query(sql).await
    }

    /// Execute generic tests defined in schema.yml and return test results.
    pub async fn execute_tests(&self, manifest: &Manifest) -> anyhow::Result<Vec<TestResult>> {
        let mut results = Vec::new();

        for (_id, node) in &manifest.nodes {
            let (model_name, model_schema, columns) = match node {
                ManifestNode::Model(m) => (&m.name, &m.config.schema, &m.columns),
                _ => continue,
            };

            let resolved_schema =
                generate_schema_name(model_schema.as_deref(), &self.target_schema);
            let qm = qualified_quoted(&resolved_schema, model_name);

            for col in columns {
                for test_def in &col.tests {
                    let (test_name, test_sql) = match test_def {
                        TestDef::Simple(name) => {
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
                                let to_schema = manifest
                                    .nodes
                                    .values()
                                    .find_map(|n| match n {
                                        ManifestNode::Model(m) if m.name == to_model => {
                                            Some(m.config.schema.clone())
                                        }
                                        _ => None,
                                    })
                                    .flatten();
                                let to_resolved = generate_schema_name(
                                    to_schema.as_deref(),
                                    &self.target_schema,
                                );
                                let qt = qualified_quoted(&to_resolved, &to_model);
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
                    match self.adapter.run_test_query(&test_sql).await {
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

        // Run singular tests (ManifestNode::Test nodes with compiled SQL)
        for (_id, node) in &manifest.nodes {
            let test = match node {
                ManifestNode::Test(t) => t,
                _ => continue,
            };

            // Only run singular tests (those without test_metadata)
            if test.test_metadata.is_some() {
                continue;
            }

            let Some(compiled_sql) = &test.compiled_sql else {
                continue;
            };

            let model_name = test
                .depends_on
                .refs
                .first()
                .map(|r| r.model_name.clone())
                .unwrap_or_default();

            let start = Instant::now();
            match self.adapter.run_test_query(compiled_sql).await {
                Ok(failure_count) => {
                    let status = if failure_count == 0 {
                        TestStatus::Pass
                    } else {
                        TestStatus::Fail
                    };
                    results.push(TestResult {
                        test_name: test.name.clone(),
                        model_name: model_name.clone(),
                        column_name: String::new(),
                        status,
                        failures: failure_count,
                        duration: start.elapsed(),
                        message: None,
                    });
                }
                Err(e) => {
                    results.push(TestResult {
                        test_name: test.name.clone(),
                        model_name,
                        column_name: String::new(),
                        status: TestStatus::Error,
                        failures: 0,
                        duration: start.elapsed(),
                        message: Some(e.to_string()),
                    });
                }
            }
        }

        Ok(results)
    }
}

impl Default for Executor {
    fn default() -> Self {
        Self::new("public")
    }
}

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Helper functions for test SQL generation
// ---------------------------------------------------------------------------

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
