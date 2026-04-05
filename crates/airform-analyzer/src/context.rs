use crate::cache::AnalysisCache;
use crate::catalog::Catalog;
use crate::contracts::{self, ContractViolation};
use crate::dialect::{self, SqlDialect};
use crate::error::AnalyzerDiagnostic;
use crate::lineage::{self, ColumnLineageGraph};
use airform_core::{Manifest, ManifestNode, Materialization};
use airform_graph::DbtGraph;
use datafusion::arrow::datatypes::{DataType, Field, Schema, SchemaRef};
use datafusion::datasource::MemTable;
use datafusion::prelude::*;
use std::collections::HashMap;
use std::path::Path;
use std::sync::Arc;

/// Result of analyzing a compiled manifest.
pub struct AnalysisResult {
    /// Inferred output schemas per table name (model/seed/source name -> Arrow Schema).
    pub schemas: HashMap<String, SchemaRef>,
    /// Column-level lineage derived from logical plans.
    pub lineage: ColumnLineageGraph,
    /// Non-fatal diagnostics collected during analysis.
    pub diagnostics: Vec<AnalyzerDiagnostic>,
    /// Number of models that were served from cache (skipped re-analysis).
    pub cached_count: usize,
    /// Contract violations found during analysis.
    pub contract_violations: Vec<ContractViolation>,
}

/// Analyzes compiled SQL by producing DataFusion logical plans.
///
/// The analyzer registers empty tables with the correct schemas, then plans
/// each model's SQL in topological order. This validates SQL correctness and
/// extracts column-level lineage without executing any queries.
pub struct Analyzer {
    ctx: SessionContext,
    schemas: HashMap<String, SchemaRef>,
    diagnostics: Vec<AnalyzerDiagnostic>,
    dialect: SqlDialect,
}

impl Analyzer {
    fn new(dialect: SqlDialect) -> Self {
        Self {
            ctx: SessionContext::new(),
            schemas: HashMap::new(),
            diagnostics: Vec::new(),
            dialect,
        }
    }

    /// Run full analysis on a compiled manifest.
    ///
    /// Parameters:
    /// - `manifest`: The compiled manifest with all models, sources, seeds
    /// - `graph`: The dependency graph
    /// - `project_dir`: Project root (for loading catalog.yml)
    /// - `cache`: Optional analysis cache for incremental analysis
    pub async fn analyze(
        manifest: &Manifest,
        graph: &DbtGraph,
        project_dir: Option<&Path>,
        mut cache: Option<&mut AnalysisCache>,
        adapter_type: Option<&str>,
    ) -> anyhow::Result<AnalysisResult> {
        let dialect = adapter_type
            .map(SqlDialect::from_adapter_type)
            .unwrap_or(SqlDialect::Generic);
        let mut analyzer = Self::new(dialect);

        // Load catalog for source schema resolution
        let catalog = project_dir
            .map(Catalog::load)
            .unwrap_or_default();

        // 1. Register sources (from schema.yml, catalog, or seed CSV inference)
        analyzer.register_sources(manifest, &catalog).await;

        // 2. Register seeds (from CSV column definitions or schema.yml)
        analyzer.register_seeds(manifest).await;

        // 3. Walk models in topological order
        let order = graph.topological_sort()?;
        let mut lineage_graph = ColumnLineageGraph::default();
        let mut cached_count = 0;

        for unique_id in &order {
            let Some(ManifestNode::Model(model)) = manifest.nodes.get(unique_id) else {
                continue;
            };

            // Skip ephemeral models — they're inlined as CTEs
            if model.config.materialized == Materialization::Ephemeral {
                continue;
            }

            let Some(sql) = &model.compiled_sql else {
                continue;
            };

            let table_name = model
                .config
                .alias
                .as_deref()
                .unwrap_or(&model.name);

            // Check incremental cache: skip if compiled SQL and upstream schemas unchanged
            if let Some(ref cache) = cache {
                if cache.is_fresh(table_name, sql, &analyzer.schemas) {
                    if let Some(schema) = cache.restore_schema(table_name) {
                        tracing::debug!("Cache hit for model {}", model.name);
                        analyzer.register_empty_table(table_name, schema).await;
                        cached_count += 1;
                        continue;
                    }
                }
            }

            // Normalize dialect-specific SQL before planning
            let normalized_sql = dialect::normalize_sql(sql, &analyzer.dialect);

            match analyzer.ctx.sql(&normalized_sql).await {
                Ok(df) => {
                    let plan = df.logical_plan();

                    // Expand wildcards: if the plan's output has fields, use them
                    let schema = Arc::new(Schema::new(
                        plan.schema()
                            .fields()
                            .iter()
                            .map(|f| {
                                Field::new(f.name(), f.data_type().clone(), f.is_nullable())
                            })
                            .collect::<Vec<_>>(),
                    ));

                    // Extract lineage from the logical plan
                    let edges = lineage::extract_lineage_from_plan(plan, &model.name);
                    lineage_graph.edges.extend(edges);

                    // Register this model's output schema for downstream consumers
                    analyzer
                        .register_empty_table(table_name, schema.clone())
                        .await;

                    // Update cache
                    if let Some(ref mut cache) = cache {
                        cache.update(table_name, sql, &schema, &analyzer.schemas);
                    }
                }
                Err(e) => {
                    // Fallback: if model has schema.yml columns, register those
                    // so downstream models can still be analyzed
                    if !model.columns.is_empty() {
                        let fields: Vec<Field> = model
                            .columns
                            .iter()
                            .map(|c| {
                                let dt = dbt_type_to_arrow(c.data_type.as_deref());
                                Field::new(&c.name, dt, true)
                            })
                            .collect();
                        let schema = Arc::new(Schema::new(fields));
                        analyzer
                            .register_empty_table(table_name, schema)
                            .await;
                        tracing::debug!(
                            "SQL planning failed for {}, using schema.yml columns as fallback",
                            model.name
                        );
                    }

                    analyzer.diagnostics.push(AnalyzerDiagnostic::SqlError {
                        model: model.name.clone(),
                        message: e.to_string(),
                    });
                }
            }
        }

        let contract_violations =
            contracts::validate_contracts(manifest, &analyzer.schemas);

        Ok(AnalysisResult {
            schemas: analyzer.schemas,
            lineage: lineage_graph,
            diagnostics: analyzer.diagnostics,
            cached_count,
            contract_violations,
        })
    }

    /// Register source tables from schema.yml column definitions, catalog, or seed CSV inference.
    async fn register_sources(&mut self, manifest: &Manifest, catalog: &Catalog) {
        // Build a map of seed name -> CSV path for fallback type inference
        let seed_paths: HashMap<String, std::path::PathBuf> = manifest
            .nodes
            .values()
            .filter_map(|n| {
                if let ManifestNode::Seed(seed) = n {
                    Some((seed.name.clone(), seed.path.clone()))
                } else {
                    None
                }
            })
            .collect();

        for source in manifest.sources.values() {
            let table_name = source.table_identifier();

            if source.columns.is_empty() {
                // Try catalog first
                if let Some(cols) = catalog.lookup(&source.source_name, &source.name) {
                    let fields: Vec<Field> = cols
                        .iter()
                        .map(|c| {
                            let dt = dbt_type_to_arrow(Some(&c.data_type));
                            Field::new(&c.name, dt, true)
                        })
                        .collect();
                    let schema = Arc::new(Schema::new(fields));
                    self.register_empty_table(table_name, schema).await;
                    continue;
                }

                // Fall back to matching seed CSV
                if let Some(csv_path) = seed_paths.get(table_name) {
                    if let Ok(schema) = infer_csv_schema(csv_path) {
                        self.register_empty_table(table_name, Arc::new(schema)).await;
                        continue;
                    }
                }

                self.diagnostics.push(AnalyzerDiagnostic::SchemaUnavailable {
                    node: format!("source:{}.{}", source.source_name, source.name),
                });
                continue;
            }

            // Check if all columns lack data_type — try catalog, then seed CSV
            let all_untyped = source.columns.iter().all(|c| c.data_type.is_none());
            if all_untyped {
                // Try catalog for typed columns
                if let Some(cols) = catalog.lookup(&source.source_name, &source.name) {
                    let fields: Vec<Field> = cols
                        .iter()
                        .map(|c| {
                            let dt = dbt_type_to_arrow(Some(&c.data_type));
                            Field::new(&c.name, dt, true)
                        })
                        .collect();
                    let schema = Arc::new(Schema::new(fields));
                    self.register_empty_table(table_name, schema).await;
                    continue;
                }

                if let Some(csv_path) = seed_paths.get(table_name) {
                    if let Ok(schema) = infer_csv_schema(csv_path) {
                        self.register_empty_table(table_name, Arc::new(schema)).await;
                        continue;
                    }
                }
            }

            let fields: Vec<Field> = source
                .columns
                .iter()
                .map(|c| {
                    let dt = dbt_type_to_arrow(c.data_type.as_deref());
                    Field::new(&c.name, dt, true)
                })
                .collect();
            let schema = Arc::new(Schema::new(fields));
            self.register_empty_table(table_name, schema).await;
        }
    }

    /// Register seed tables. Seeds always have schema.yml columns or
    /// we can infer from the column definitions attached during parsing.
    async fn register_seeds(&mut self, manifest: &Manifest) {
        for node in manifest.nodes.values() {
            let ManifestNode::Seed(seed) = node else {
                continue;
            };

            if seed.columns.is_empty() {
                if let Ok(schema) = infer_csv_schema(&seed.path) {
                    self.register_empty_table(&seed.name, Arc::new(schema)).await;
                } else {
                    self.diagnostics.push(AnalyzerDiagnostic::SchemaUnavailable {
                        node: format!("seed:{}", seed.name),
                    });
                }
                continue;
            }

            let fields: Vec<Field> = seed
                .columns
                .iter()
                .map(|c| {
                    let dt = dbt_type_to_arrow(c.data_type.as_deref());
                    Field::new(&c.name, dt, true)
                })
                .collect();
            let schema = Arc::new(Schema::new(fields));
            self.register_empty_table(&seed.name, schema).await;
        }
    }

    /// Register an empty table with the given schema in the DataFusion context.
    async fn register_empty_table(&mut self, name: &str, schema: SchemaRef) {
        self.schemas.insert(name.to_string(), schema.clone());
        let table = MemTable::try_new(schema, vec![]).unwrap();
        let _ = self.ctx.deregister_table(name);
        let _ = self.ctx.register_table(name, Arc::new(table));
    }
}

/// Infer schema from a CSV file by reading the header and sampling data rows.
fn infer_csv_schema(path: &std::path::Path) -> anyhow::Result<Schema> {
    use std::io::BufRead;
    let file = std::fs::File::open(path)?;
    let reader = std::io::BufReader::new(file);
    let mut lines = reader.lines();

    let header = lines
        .next()
        .ok_or_else(|| anyhow::anyhow!("empty CSV"))??;
    let col_names: Vec<&str> = header.split(',').map(|s| s.trim()).collect();
    let num_cols = col_names.len();

    // Sample up to 10 data rows to infer types
    let mut col_types: Vec<DataType> = vec![DataType::Int64; num_cols]; // start optimistic
    let mut row_count = 0;

    for line in lines.take(10) {
        let line = line?;
        let values: Vec<&str> = line.split(',').map(|s| s.trim()).collect();
        row_count += 1;

        for (i, val) in values.iter().enumerate() {
            if i >= num_cols {
                break;
            }
            if val.is_empty() {
                continue; // null — doesn't affect type inference
            }
            let inferred = infer_value_type(val);
            col_types[i] = widen_type(&col_types[i], &inferred);
        }
    }

    // If no data rows, default everything to Utf8
    if row_count == 0 {
        col_types = vec![DataType::Utf8; num_cols];
    }

    let fields: Vec<Field> = col_names
        .iter()
        .enumerate()
        .map(|(i, name)| Field::new(*name, col_types[i].clone(), true))
        .collect();
    Ok(Schema::new(fields))
}

fn infer_value_type(val: &str) -> DataType {
    if val.parse::<i64>().is_ok() {
        DataType::Int64
    } else if val.parse::<f64>().is_ok() {
        DataType::Float64
    } else if val.eq_ignore_ascii_case("true") || val.eq_ignore_ascii_case("false") {
        DataType::Boolean
    } else {
        DataType::Utf8
    }
}

/// Widen type to accommodate both observed types.
fn widen_type(current: &DataType, observed: &DataType) -> DataType {
    if current == observed {
        return current.clone();
    }
    match (current, observed) {
        (DataType::Int64, DataType::Float64) | (DataType::Float64, DataType::Int64) => {
            DataType::Float64
        }
        (DataType::Utf8, _) | (_, DataType::Utf8) => DataType::Utf8,
        _ => DataType::Utf8,
    }
}

/// Map dbt/schema.yml type strings to Arrow DataType.
pub(crate) fn dbt_type_to_arrow(type_str: Option<&str>) -> DataType {
    match type_str.map(|s| s.to_lowercase()).as_deref() {
        Some("integer" | "int" | "bigint" | "int64") => DataType::Int64,
        Some("smallint" | "int32") => DataType::Int32,
        Some("float" | "double" | "numeric" | "decimal" | "float64" | "number") => {
            DataType::Float64
        }
        Some("boolean" | "bool") => DataType::Boolean,
        Some("date") => DataType::Date32,
        Some("timestamp" | "datetime" | "timestamp_ntz") => {
            DataType::Timestamp(datafusion::arrow::datatypes::TimeUnit::Nanosecond, None)
        }
        Some("varchar" | "string" | "text" | "char") | None => DataType::Utf8,
        Some(_) => DataType::Utf8, // unknown types default to Utf8
    }
}
