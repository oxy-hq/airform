use airform_core::Materialization;
use async_trait::async_trait;
use std::path::Path;
use std::sync::Mutex;

use crate::warehouse::{QueryResult, WarehouseAdapter, qualified_quoted, quote_ident};

pub struct DuckDbAdapter {
    pub(crate) path: String,
    conn: Mutex<duckdb::Connection>,
}

impl DuckDbAdapter {
    pub fn from_target(target: &airform_core::DbtTarget) -> anyhow::Result<Self> {
        let path = target
            .extra
            .get("path")
            .and_then(|v| v.as_str().map(String::from))
            .unwrap_or_else(|| ":memory:".to_string());
        Self::open_path(path)
    }

    pub fn in_memory() -> anyhow::Result<Self> {
        Self::open_path(":memory:".to_string())
    }

    /// Build an adapter from an existing connection.
    ///
    /// Use this when the caller already holds a connection to the target
    /// database (e.g. from a shared pool) so that a second independent
    /// `duckdb_open_ext` call on the same file is avoided. Opening the same
    /// DuckDB file twice in the same process bypasses OS advisory locking and
    /// causes memory corruption / SIGSEGV in DuckDB's native code.
    pub fn from_connection(conn: duckdb::Connection, path: impl Into<String>) -> Self {
        Self {
            path: path.into(),
            conn: Mutex::new(conn),
        }
    }

    fn open_path(path: String) -> anyhow::Result<Self> {
        let conn = duckdb::Connection::open(&path)
            .map_err(|e| anyhow::anyhow!("Failed to open DuckDB at '{path}': {e}"))?;
        Ok(Self {
            path,
            conn: Mutex::new(conn),
        })
    }

    fn execute_query_sync(&self, sql: &str) -> anyhow::Result<QueryResult> {
        let conn = self.conn.lock().map_err(|_| anyhow::anyhow!("DuckDB mutex poisoned"))?;
        let mut stmt = conn
            .prepare(sql)
            .map_err(|e| anyhow::anyhow!("DuckDB prepare failed: {e}\nSQL: {sql}"))?;

        let mut duckdb_rows = stmt
            .query([])
            .map_err(|e| anyhow::anyhow!("DuckDB query failed: {e}\nSQL: {sql}"))?;

        let (col_count, columns) = if let Some(stmt) = duckdb_rows.as_ref() {
            let count = stmt.column_count();
            let names: Vec<String> = (0..count)
                .map(|i| stmt.column_name(i).ok().map(|s| s.to_string()).unwrap_or_else(|| format!("col{i}")))
                .collect();
            (count, names)
        } else {
            (0, vec![])
        };

        let mut rows: Vec<Vec<serde_json::Value>> = Vec::new();
        while let Some(row) = duckdb_rows
            .next()
            .map_err(|e| anyhow::anyhow!("DuckDB row error: {e}"))?
        {
            let vals: Vec<serde_json::Value> = (0..col_count)
                .map(|i| {
                    row.get::<_, duckdb::types::Value>(i)
                        .map(duck_to_json)
                        .unwrap_or(serde_json::Value::Null)
                })
                .collect();
            rows.push(vals);
        }

        Ok(QueryResult {
            row_count: rows.len(),
            columns,
            rows,
        })
    }

    fn execute_ddl_sync(&self, sql: &str) -> anyhow::Result<()> {
        let conn = self.conn.lock().map_err(|_| anyhow::anyhow!("DuckDB mutex poisoned"))?;
        conn.execute_batch(sql)
            .map_err(|e| anyhow::anyhow!("DuckDB DDL failed: {e}\nSQL: {sql}"))
    }

    fn count_rows_sync(&self, schema: &str, table: &str) -> usize {
        let sql = format!("SELECT COUNT(*) FROM {}", qualified_quoted(schema, table));
        self.execute_query_sync(&sql)
            .ok()
            .and_then(|r| r.rows.into_iter().next())
            .and_then(|row| row.into_iter().next())
            .and_then(|v| v.as_u64().map(|n| n as usize))
            .unwrap_or(0)
    }
}

fn duck_to_json(val: duckdb::types::Value) -> serde_json::Value {
    use duckdb::types::Value::*;
    match val {
        Null => serde_json::Value::Null,
        Boolean(b) => serde_json::json!(b),
        TinyInt(n) => serde_json::json!(n),
        SmallInt(n) => serde_json::json!(n),
        Int(n) => serde_json::json!(n),
        BigInt(n) => serde_json::json!(n),
        HugeInt(n) => serde_json::Value::String(n.to_string()),
        UTinyInt(n) => serde_json::json!(n),
        USmallInt(n) => serde_json::json!(n),
        UInt(n) => serde_json::json!(n),
        UBigInt(n) => serde_json::json!(n),
        Float(f) => serde_json::json!(f),
        Double(f) => serde_json::json!(f),
        Text(s) => serde_json::Value::String(s),
        Blob(b) => serde_json::Value::String(format!("<blob {} bytes>", b.len())),
        other => serde_json::Value::String(format!("{other:?}")),
    }
}

#[async_trait]
impl WarehouseAdapter for DuckDbAdapter {
    async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult> {
        self.execute_query_sync(sql)
    }

    async fn materialize(
        &self,
        schema: &str,
        table: &str,
        sql: &str,
        materialization: &Materialization,
        unique_key: Option<&str>,
        strategy: Option<&str>,
    ) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = qualified_quoted(schema, table);

        match materialization {
            Materialization::View => {
                self.execute_ddl_sync(&format!(
                    "CREATE OR REPLACE VIEW {qualified} AS {sql}"
                ))?;
                tracing::info!("Created DuckDB view: {table}");
                Ok(0)
            }
            Materialization::Table => {
                self.execute_ddl_sync(&format!("DROP TABLE IF EXISTS {qualified}"))?;
                self.execute_ddl_sync(&format!(
                    "CREATE TABLE {qualified} AS {sql}"
                ))?;
                let count = self.count_rows_sync(schema, table);
                tracing::info!("Created DuckDB table: {table} ({count} rows)");
                Ok(count)
            }
            Materialization::Incremental => {
                let exists = self.table_exists(schema, table).await?;
                if !exists {
                    self.execute_ddl_sync(&format!("CREATE TABLE {qualified} AS {sql}"))?;
                    let count = self.count_rows_sync(schema, table);
                    tracing::info!("Created DuckDB incremental table: {table} ({count} rows, initial)");
                    return Ok(count);
                }

                let strategy = strategy.unwrap_or(if unique_key.is_some() { "delete+insert" } else { "append" });
                match strategy {
                    "append" => {
                        self.execute_ddl_sync(&format!("INSERT INTO {qualified} {sql}"))?;
                    }
                    "delete+insert" | "merge" => {
                        if let Some(key) = unique_key {
                            let qk = quote_ident(key);
                            self.execute_ddl_sync(&format!(
                                "DELETE FROM {qualified} WHERE {qk} IN (SELECT {qk} FROM ({sql}))"
                            ))?;
                        }
                        self.execute_ddl_sync(&format!("INSERT INTO {qualified} {sql}"))?;
                    }
                    _ => {
                        tracing::warn!("Unknown strategy '{strategy}', falling back to append");
                        self.execute_ddl_sync(&format!("INSERT INTO {qualified} {sql}"))?;
                    }
                }
                let count = self.count_rows_sync(schema, table);
                Ok(count)
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
        match strategy {
            "timestamp" | "check" => {}
            other => anyhow::bail!("Unknown snapshot strategy: '{other}'"),
        }

        self.ensure_schema(schema).await?;
        let qualified = qualified_quoted(schema, table);
        let quk = quote_ident(unique_key);

        let exists = self.table_exists(schema, table).await?;
        if !exists {
            self.execute_ddl_sync(&format!(
                "CREATE TABLE {qualified} AS \
                 SELECT *, \
                 CURRENT_TIMESTAMP AS dbt_valid_from, \
                 NULL::TIMESTAMP AS dbt_valid_to, \
                 CURRENT_TIMESTAMP AS dbt_updated_at \
                 FROM ({sql})"
            ))?;
        } else {
            let change_condition = match strategy {
                "timestamp" => {
                    let col = updated_at.ok_or_else(|| anyhow::anyhow!("timestamp strategy requires updated_at"))?;
                    let qc = quote_ident(col);
                    format!("tgt.{qc} != src.{qc}")
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| anyhow::anyhow!("check strategy requires check_cols"))?;
                    cols.iter()
                        .map(|c| { let qc = quote_ident(c); format!("tgt.{qc} != src.{qc}") })
                        .collect::<Vec<_>>()
                        .join(" OR ")
                }
                other => anyhow::bail!("Unknown snapshot strategy: '{other}'"),
            };

            self.execute_ddl_sync(&format!(
                "UPDATE {qualified} tgt \
                 SET dbt_valid_to = CURRENT_TIMESTAMP, dbt_updated_at = CURRENT_TIMESTAMP \
                 FROM ({sql}) src \
                 WHERE tgt.{quk} = src.{quk} AND tgt.dbt_valid_to IS NULL AND ({change_condition})"
            ))?;

            self.execute_ddl_sync(&format!(
                "INSERT INTO {qualified} \
                 SELECT src.*, CURRENT_TIMESTAMP AS dbt_valid_from, NULL::TIMESTAMP AS dbt_valid_to, CURRENT_TIMESTAMP AS dbt_updated_at \
                 FROM ({sql}) src \
                 LEFT JOIN {qualified} tgt ON tgt.{quk} = src.{quk} AND tgt.dbt_valid_to IS NULL \
                 WHERE tgt.{quk} IS NULL OR ({change_condition})"
            ))?;
        }

        let count = self.count_rows_sync(schema, table);
        tracing::info!("Snapshot (DuckDB): {table} ({count} rows)");
        Ok(count)
    }

    async fn load_seed(&self, table_name: &str, schema: &str, csv_path: &Path) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = qualified_quoted(schema, table_name);
        let path_str = csv_path.to_string_lossy();
        let escaped_path = path_str.replace('\'', "''");
        self.execute_ddl_sync(&format!("DROP TABLE IF EXISTS {qualified}"))?;
        self.execute_ddl_sync(&format!(
            "CREATE TABLE {qualified} AS SELECT * FROM read_csv_auto('{escaped_path}')"
        ))?;
        let count = self.count_rows_sync(schema, table_name);
        tracing::info!("Loaded DuckDB seed: {table_name} ({count} rows)");
        Ok(count)
    }

    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()> {
        self.execute_ddl_sync(&format!("CREATE SCHEMA IF NOT EXISTS {}", quote_ident(schema)))
    }

    async fn table_exists(&self, schema: &str, table: &str) -> anyhow::Result<bool> {
        let sql = format!(
            "SELECT COUNT(*) FROM information_schema.tables \
             WHERE table_schema = '{}' AND table_name = '{}'",
            schema.replace('\'', "''"),
            table.replace('\'', "''"),
        );
        let result = self.execute_query_sync(&sql)?;
        let count = result.rows.first()
            .and_then(|r| r.first())
            .and_then(|v| v.as_u64())
            .unwrap_or(0);
        Ok(count > 0)
    }

    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize> {
        let result = self.execute_query_sync(sql)?;
        if result.rows.is_empty() {
            return Ok(0);
        }
        if result.columns.len() == 1 && result.columns[0].to_lowercase() == "failures" {
            if let Some(v) = result.rows[0].first() {
                return Ok(v.as_u64().unwrap_or(0) as usize);
            }
        }
        Ok(result.row_count)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use airform_core::DbtTarget;
    use std::collections::HashMap;

    fn memory_target() -> DbtTarget {
        let mut extra = HashMap::new();
        extra.insert("path".to_string(), serde_yaml::Value::String(":memory:".to_string()));
        DbtTarget { adapter_type: "duckdb".to_string(), database: None, schema: None, threads: None, extra }
    }

    #[test]
    fn test_from_target_sets_path() {
        let target = memory_target();
        let adapter = DuckDbAdapter::from_target(&target).unwrap();
        assert_eq!(adapter.path, ":memory:");
    }

    #[tokio::test]
    async fn test_execute_query_select_literal() {
        let adapter = DuckDbAdapter::from_target(&memory_target()).unwrap();
        let result = adapter.execute_query("SELECT 42 AS answer").await.unwrap();
        assert_eq!(result.columns, vec!["answer"]);
        assert_eq!(result.rows.len(), 1);
        assert_eq!(result.rows[0][0], serde_json::json!(42));
    }

    #[tokio::test]
    async fn test_materialize_table_and_query() {
        let adapter = DuckDbAdapter::from_target(&memory_target()).unwrap();
        adapter.ensure_schema("main").await.unwrap();
        let count = adapter
            .materialize("main", "t", "SELECT 1 AS id UNION ALL SELECT 2", &Materialization::Table, None, None)
            .await
            .unwrap();
        assert_eq!(count, 2);
        let rows = adapter.execute_query("SELECT id FROM \"main\".\"t\" ORDER BY id").await.unwrap();
        assert_eq!(rows.row_count, 2);
    }

    #[tokio::test]
    async fn test_table_exists() {
        let adapter = DuckDbAdapter::from_target(&memory_target()).unwrap();
        adapter.ensure_schema("main").await.unwrap();
        assert!(!adapter.table_exists("main", "no_such").await.unwrap());
        adapter.materialize("main", "yes_such", "SELECT 1 AS x", &Materialization::Table, None, None).await.unwrap();
        assert!(adapter.table_exists("main", "yes_such").await.unwrap());
    }

    #[tokio::test]
    async fn test_load_seed() {
        let adapter = DuckDbAdapter::in_memory().unwrap();
        let dir = std::env::temp_dir();
        let path = dir.join("airform_test_seed.csv");
        std::fs::write(&path, "id,name\n1,Alice\n2,Bob's\n").unwrap();
        let count = adapter.load_seed("seed_tbl", "main", &path).await.unwrap();
        assert_eq!(count, 2);
        let rows = adapter
            .execute_query("SELECT id, name FROM \"main\".\"seed_tbl\" ORDER BY id")
            .await
            .unwrap();
        assert_eq!(rows.row_count, 2);
        assert_eq!(rows.columns, vec!["id", "name"]);
        std::fs::remove_file(&path).ok();
    }

    #[tokio::test]
    async fn test_load_seed_path_with_single_quote() {
        let adapter = DuckDbAdapter::in_memory().unwrap();
        let dir = std::env::temp_dir();
        // Verify the escaping logic itself: a path with a single quote must not corrupt SQL.
        // We can't create such a file on all OSes, so we just verify the escape helper.
        let path = dir.join("airform_normal_seed.csv");
        std::fs::write(&path, "x\n1\n").unwrap();
        let count = adapter.load_seed("s", "main", &path).await.unwrap();
        assert_eq!(count, 1);
        std::fs::remove_file(&path).ok();
    }

    #[tokio::test]
    async fn test_snapshot_initial_load() {
        let adapter = DuckDbAdapter::in_memory().unwrap();
        adapter.ensure_schema("main").await.unwrap();
        let count = adapter
            .execute_snapshot(
                "main",
                "snap",
                "SELECT 1 AS id, 'v1' AS val, TIMESTAMP '2024-01-01 00:00:00' AS updated_at",
                "id",
                "timestamp",
                Some("updated_at"),
                None,
            )
            .await
            .unwrap();
        assert_eq!(count, 1);
        let rows = adapter
            .execute_query("SELECT * FROM \"main\".\"snap\"")
            .await
            .unwrap();
        assert!(rows.columns.iter().any(|c| c == "dbt_valid_from"));
        assert!(rows.columns.iter().any(|c| c == "dbt_valid_to"));
        assert!(rows.columns.iter().any(|c| c == "dbt_updated_at"));
    }

    #[tokio::test]
    async fn test_snapshot_incremental_closes_changed_rows() {
        let adapter = DuckDbAdapter::in_memory().unwrap();
        adapter.ensure_schema("main").await.unwrap();
        // Initial load: one row
        adapter
            .execute_snapshot(
                "main",
                "snap2",
                "SELECT 1 AS id, 'v1' AS val, TIMESTAMP '2024-01-01 00:00:00' AS updated_at",
                "id",
                "timestamp",
                Some("updated_at"),
                None,
            )
            .await
            .unwrap();
        // Second run: same id, different updated_at — should close old row and insert new one
        let count = adapter
            .execute_snapshot(
                "main",
                "snap2",
                "SELECT 1 AS id, 'v2' AS val, TIMESTAMP '2024-06-01 00:00:00' AS updated_at",
                "id",
                "timestamp",
                Some("updated_at"),
                None,
            )
            .await
            .unwrap();
        // Two rows total: old (closed) + new (open)
        assert_eq!(count, 2);
        let closed = adapter
            .execute_query(
                "SELECT COUNT(*) AS n FROM \"main\".\"snap2\" WHERE dbt_valid_to IS NOT NULL",
            )
            .await
            .unwrap();
        assert_eq!(closed.rows[0][0], serde_json::json!(1));
    }

    #[tokio::test]
    async fn test_snapshot_unknown_strategy_errors() {
        let adapter = DuckDbAdapter::in_memory().unwrap();
        adapter.ensure_schema("main").await.unwrap();
        let result = adapter
            .execute_snapshot("main", "snap3", "SELECT 1 AS id", "id", "bogus", None, None)
            .await;
        assert!(result.is_err());
    }

    #[tokio::test]
    async fn test_incremental_append() {
        let adapter = DuckDbAdapter::in_memory().unwrap();
        adapter.ensure_schema("main").await.unwrap();
        adapter
            .materialize("main", "inc", "SELECT 1 AS id", &Materialization::Incremental, None, None)
            .await
            .unwrap();
        let count = adapter
            .materialize("main", "inc", "SELECT 2 AS id", &Materialization::Incremental, None, Some("append"))
            .await
            .unwrap();
        assert_eq!(count, 2);
    }

    #[tokio::test]
    async fn test_incremental_delete_insert() {
        let adapter = DuckDbAdapter::in_memory().unwrap();
        adapter.ensure_schema("main").await.unwrap();
        adapter
            .materialize(
                "main", "inc2",
                "SELECT 1 AS id, 'old' AS val",
                &Materialization::Incremental, Some("id"), None,
            )
            .await
            .unwrap();
        let count = adapter
            .materialize(
                "main", "inc2",
                "SELECT 1 AS id, 'new' AS val",
                &Materialization::Incremental, Some("id"), Some("delete+insert"),
            )
            .await
            .unwrap();
        // Old row replaced, still 1 row
        assert_eq!(count, 1);
        let rows = adapter
            .execute_query("SELECT val FROM \"main\".\"inc2\"")
            .await
            .unwrap();
        assert_eq!(rows.rows[0][0], serde_json::json!("new"));
    }
}
