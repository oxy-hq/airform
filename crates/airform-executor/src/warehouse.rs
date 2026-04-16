use airform_core::{Manifest, Materialization};
use airform_graph::DbtGraph;
use async_trait::async_trait;
use std::path::Path;

/// Result from a SELECT query, adapter-agnostic.
#[derive(Debug, Clone)]
pub struct QueryResult {
    pub row_count: usize,
    pub columns: Vec<String>,
    pub rows: Vec<Vec<serde_json::Value>>,
}

impl QueryResult {
    /// Format as an ASCII table for CLI display.
    pub fn format_table(&self) -> String {
        if self.rows.is_empty() && self.columns.is_empty() {
            return "(no results)".to_string();
        }

        let mut widths: Vec<usize> = self.columns.iter().map(|c| c.len()).collect();
        for row in &self.rows {
            for (i, val) in row.iter().enumerate() {
                if i < widths.len() {
                    widths[i] = widths[i].max(value_display_str(val).len());
                }
            }
        }

        let mut out = String::new();
        // Header
        let header: Vec<String> = self
            .columns
            .iter()
            .enumerate()
            .map(|(i, c)| format!("{:width$}", c, width = widths[i]))
            .collect();
        out.push_str(&header.join(" | "));
        out.push('\n');
        // Separator
        let sep: Vec<String> = widths.iter().map(|w| "-".repeat(*w)).collect();
        out.push_str(&sep.join("-+-"));
        out.push('\n');
        // Rows
        for row in &self.rows {
            let vals: Vec<String> = row
                .iter()
                .enumerate()
                .map(|(i, v)| {
                    let s = value_display_str(v);
                    format!("{:width$}", s, width = widths.get(i).copied().unwrap_or(0))
                })
                .collect();
            out.push_str(&vals.join(" | "));
            out.push('\n');
        }

        out
    }
}

fn value_display_str(v: &serde_json::Value) -> String {
    match v {
        serde_json::Value::Null => "NULL".to_string(),
        serde_json::Value::String(s) => s.clone(),
        serde_json::Value::Number(n) => n.to_string(),
        serde_json::Value::Bool(b) => b.to_string(),
        v => v.to_string(),
    }
}

/// Trait for executing SQL against a data warehouse.
///
/// Implementors handle the dialect-specific details of running SQL,
/// materializing models, loading seeds, etc. The `Executor` orchestrates
/// the dbt graph and delegates actual SQL execution to the adapter.
#[async_trait]
pub trait WarehouseAdapter: Send + Sync {
    /// Execute a SELECT query and return tabular results.
    async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult>;

    /// Materialize a model as a table or view.
    /// The adapter handles SQL dialect fixes and DDL generation.
    async fn materialize(
        &self,
        schema: &str,
        table: &str,
        sql: &str,
        materialization: &Materialization,
        unique_key: Option<&str>,
        strategy: Option<&str>,
    ) -> anyhow::Result<usize>;

    /// Execute a snapshot with SCD Type 2 logic.
    async fn execute_snapshot(
        &self,
        schema: &str,
        table: &str,
        sql: &str,
        unique_key: &str,
        strategy: &str,
        updated_at: Option<&str>,
        check_cols: Option<&[String]>,
    ) -> anyhow::Result<usize>;

    /// Load a CSV seed file into a table.
    async fn load_seed(
        &self,
        table_name: &str,
        schema: &str,
        csv_path: &Path,
    ) -> anyhow::Result<usize>;

    /// Ensure a schema exists, creating it if necessary.
    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()>;

    /// Check if a table exists in the given schema.
    async fn table_exists(&self, schema: &str, table: &str) -> anyhow::Result<bool>;

    /// Run a test query and return the number of failing rows.
    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize>;

    /// Register empty stub tables for source definitions.
    /// Cloud adapters return Ok(0) since sources exist in the warehouse.
    async fn register_sources(
        &self,
        _manifest: &Manifest,
        _target_schema: &str,
    ) -> anyhow::Result<usize> {
        Ok(0)
    }

    /// Register virtual information schema tables.
    /// Only meaningful for local adapters (DataFusion).
    async fn register_info_schema(
        &self,
        _manifest: &Manifest,
        _graph: &DbtGraph,
    ) -> anyhow::Result<()> {
        Ok(())
    }
}

// ---------------------------------------------------------------------------
// Shared utilities used by both the Executor and adapters
// ---------------------------------------------------------------------------

/// Quote a SQL identifier to prevent injection via model/column names.
/// Doubles any internal double-quotes, then wraps in double-quotes.
pub(crate) fn quote_ident(ident: &str) -> String {
    format!("\"{}\"", ident.replace('"', "\"\""))
}

/// Build a schema-qualified, properly quoted SQL reference: "schema"."table"
pub(crate) fn qualified_quoted(schema: &str, table: &str) -> String {
    format!("{}.{}", quote_ident(schema), quote_ident(table))
}

/// Implements dbt's default `generate_schema_name` macro.
pub(crate) fn generate_schema_name(custom_schema: Option<&str>, default_schema: &str) -> String {
    match custom_schema {
        Some(custom) if !custom.is_empty() => format!("{}_{}", default_schema, custom),
        _ => default_schema.to_string(),
    }
}
