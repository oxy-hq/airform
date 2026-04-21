use airform_core::Materialization;
use async_trait::async_trait;
use std::path::Path;

use crate::csv::parse_csv_line;
use crate::warehouse::{QueryResult, WarehouseAdapter, qualified_quoted, quote_ident};

pub struct PostgresAdapter {
    client: tokio_postgres::Client,
}

impl PostgresAdapter {
    pub async fn from_target(target: &airform_core::DbtTarget) -> anyhow::Result<Self> {
        let get = |key: &str| {
            target.extra.get(key).and_then(|v| v.as_str().map(String::from))
        };
        let host = get("host").unwrap_or_else(|| "localhost".to_string());
        let port = get("port").unwrap_or_else(|| "5432".to_string());
        let user = get("user").ok_or_else(|| anyhow::anyhow!("Postgres target missing 'user'"))?;
        let password = get("password").unwrap_or_default();
        let database = target.database.clone()
            .or_else(|| get("dbname"))
            .or_else(|| get("database"))
            .unwrap_or_else(|| "postgres".to_string());

        let connstr = format!(
            "host={host} port={port} user={user} password={password} dbname={database}"
        );
        let (client, connection) = tokio_postgres::connect(&connstr, tokio_postgres::NoTls)
            .await
            .map_err(|e| anyhow::anyhow!("Failed to connect to Postgres at {host}:{port}: {e}"))?;

        tokio::spawn(async move {
            if let Err(e) = connection.await {
                tracing::error!("Postgres connection error: {e}");
            }
        });

        Ok(Self { client })
    }

    pub async fn from_env() -> anyhow::Result<Self> {
        dotenvy::dotenv().ok();
        let host = std::env::var("PGHOST").unwrap_or_else(|_| "localhost".to_string());
        let port = std::env::var("PGPORT").unwrap_or_else(|_| "5432".to_string());
        let user = std::env::var("PGUSER").map_err(|_| anyhow::anyhow!("PGUSER not set"))?;
        let password = std::env::var("PGPASSWORD").unwrap_or_default();
        let database = std::env::var("PGDATABASE").unwrap_or_else(|_| "postgres".to_string());

        let connstr = format!("host={host} port={port} user={user} password={password} dbname={database}");
        let (client, connection) = tokio_postgres::connect(&connstr, tokio_postgres::NoTls)
            .await
            .map_err(|e| anyhow::anyhow!("Failed to connect to Postgres at {host}:{port}: {e}"))?;
        tokio::spawn(async move { let _ = connection.await; });
        Ok(Self { client })
    }

    async fn execute_ddl(&self, sql: &str) -> anyhow::Result<()> {
        self.client
            .batch_execute(sql)
            .await
            .map_err(|e| anyhow::anyhow!("Postgres DDL failed: {e}\nSQL: {sql}"))
    }

    async fn count_rows(&self, schema: &str, table: &str) -> usize {
        let sql = format!("SELECT COUNT(*) FROM {}", qualified_quoted(schema, table));
        self.client
            .query_one(&sql, &[])
            .await
            .ok()
            .and_then(|row| row.try_get::<_, i64>(0).ok())
            .map(|n| n as usize)
            .unwrap_or(0)
    }
}

fn pg_rows_to_result(rows: Vec<tokio_postgres::Row>) -> QueryResult {
    if rows.is_empty() {
        return QueryResult { row_count: 0, columns: vec![], rows: vec![] };
    }
    let columns: Vec<String> = rows[0].columns().iter().map(|c| c.name().to_string()).collect();
    let data: Vec<Vec<serde_json::Value>> = rows
        .iter()
        .map(|row| {
            row.columns()
                .iter()
                .enumerate()
                .map(|(i, col)| pg_val_to_json(row, col, i))
                .collect()
        })
        .collect();
    QueryResult { row_count: data.len(), columns, rows: data }
}

fn pg_val_to_json(row: &tokio_postgres::Row, col: &tokio_postgres::Column, idx: usize) -> serde_json::Value {
    use tokio_postgres::types::Type;
    macro_rules! try_get {
        ($t:ty) => {
            if let Ok(v) = row.try_get::<_, Option<$t>>(idx) {
                return v.map_or(serde_json::Value::Null, |v| serde_json::json!(v));
            }
        };
    }
    match col.type_() {
        &Type::BOOL => { try_get!(bool); }
        &Type::INT2 => { try_get!(i16); }
        &Type::INT4 => { try_get!(i32); }
        &Type::INT8 => { try_get!(i64); }
        &Type::FLOAT4 => { try_get!(f32); }
        &Type::FLOAT8 => { try_get!(f64); }
        _ => {}
    }
    row.try_get::<_, Option<String>>(idx)
        .ok()
        .flatten()
        .map_or(serde_json::Value::Null, serde_json::Value::String)
}

#[async_trait]
impl WarehouseAdapter for PostgresAdapter {
    async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult> {
        let rows = self.client
            .query(sql, &[])
            .await
            .map_err(|e| anyhow::anyhow!("Postgres query failed: {e}\nSQL: {sql}"))?;
        Ok(pg_rows_to_result(rows))
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
                self.execute_ddl(&format!("CREATE OR REPLACE VIEW {qualified} AS {sql}")).await?;
                tracing::info!("Created Postgres view: {table}");
                Ok(0)
            }
            Materialization::Table => {
                self.execute_ddl(&format!("DROP TABLE IF EXISTS {qualified}")).await?;
                self.execute_ddl(&format!("CREATE TABLE {qualified} AS {sql}")).await?;
                let count = self.count_rows(schema, table).await;
                tracing::info!("Created Postgres table: {table} ({count} rows)");
                Ok(count)
            }
            Materialization::Incremental => {
                let exists = self.table_exists(schema, table).await?;
                if !exists {
                    self.execute_ddl(&format!("CREATE TABLE {qualified} AS {sql}")).await?;
                    let count = self.count_rows(schema, table).await;
                    return Ok(count);
                }
                let strategy = strategy.unwrap_or(if unique_key.is_some() { "delete+insert" } else { "append" });
                match strategy {
                    "append" => {
                        self.execute_ddl(&format!("INSERT INTO {qualified} {sql}")).await?;
                    }
                    "delete+insert" | "merge" => {
                        if let Some(key) = unique_key {
                            let qk = quote_ident(key);
                            self.execute_ddl(&format!(
                                "DELETE FROM {qualified} WHERE {qk} IN (SELECT {qk} FROM ({sql}) _sub)"
                            )).await?;
                        }
                        self.execute_ddl(&format!("INSERT INTO {qualified} {sql}")).await?;
                    }
                    _ => {
                        self.execute_ddl(&format!("INSERT INTO {qualified} {sql}")).await?;
                    }
                }
                Ok(self.count_rows(schema, table).await)
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
        self.ensure_schema(schema).await?;
        let qualified = qualified_quoted(schema, table);
        let quk = quote_ident(unique_key);
        let exists = self.table_exists(schema, table).await?;

        if !exists {
            self.execute_ddl(&format!(
                "CREATE TABLE {qualified} AS \
                 SELECT *, NOW() AS dbt_valid_from, NULL::TIMESTAMP AS dbt_valid_to, NOW() AS dbt_updated_at \
                 FROM ({sql}) _src"
            )).await?;
        } else {
            let change_condition = match strategy {
                "timestamp" => {
                    let col = updated_at.ok_or_else(|| anyhow::anyhow!("timestamp strategy requires updated_at"))?;
                    format!("tgt.{} != src.{}", quote_ident(col), quote_ident(col))
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| anyhow::anyhow!("check strategy requires check_cols"))?;
                    cols.iter()
                        .map(|c| format!("tgt.{0} != src.{0}", quote_ident(c)))
                        .collect::<Vec<_>>()
                        .join(" OR ")
                }
                other => anyhow::bail!("Unknown snapshot strategy: '{other}'"),
            };
            self.execute_ddl(&format!(
                "UPDATE {qualified} tgt SET dbt_valid_to = NOW(), dbt_updated_at = NOW() \
                 FROM ({sql}) src WHERE tgt.{quk} = src.{quk} AND tgt.dbt_valid_to IS NULL AND ({change_condition})"
            )).await?;
            self.execute_ddl(&format!(
                "INSERT INTO {qualified} \
                 SELECT src.*, NOW() AS dbt_valid_from, NULL::TIMESTAMP AS dbt_valid_to, NOW() AS dbt_updated_at \
                 FROM ({sql}) src \
                 LEFT JOIN {qualified} tgt ON tgt.{quk} = src.{quk} AND tgt.dbt_valid_to IS NULL \
                 WHERE tgt.{quk} IS NULL OR ({change_condition})"
            )).await?;
        }
        Ok(self.count_rows(schema, table).await)
    }

    async fn load_seed(&self, table_name: &str, schema: &str, csv_path: &Path) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = qualified_quoted(schema, table_name);
        let content = std::fs::read_to_string(csv_path)?;
        let mut lines = content.lines();
        let header = lines.next().ok_or_else(|| anyhow::anyhow!("Empty CSV"))?;
        let columns: Vec<&str> = header.split(',').map(|c| c.trim().trim_matches('"')).collect();

        let col_defs = columns.iter().map(|c| format!("{} TEXT", quote_ident(c))).collect::<Vec<_>>().join(", ");
        self.execute_ddl(&format!("DROP TABLE IF EXISTS {qualified}")).await?;
        self.execute_ddl(&format!("CREATE TABLE {qualified} ({col_defs})")).await?;

        let col_list = columns.iter().map(|c| quote_ident(c)).collect::<Vec<_>>().join(", ");
        let mut total = 0;
        let mut batch: Vec<String> = Vec::new();

        for line in lines.filter(|l| !l.trim().is_empty()) {
            let values = parse_csv_line(line);
            let val_list = values.iter()
                .map(|v| if v.is_empty() || v.eq_ignore_ascii_case("null") {
                    "NULL".to_string()
                } else {
                    format!("'{}'", v.replace('\'', "''"))
                })
                .collect::<Vec<_>>()
                .join(", ");
            batch.push(format!("({val_list})"));
            total += 1;

            if batch.len() >= 500 {
                self.execute_ddl(&format!("INSERT INTO {qualified} ({col_list}) VALUES {}", batch.join(", "))).await?;
                batch.clear();
            }
        }
        if !batch.is_empty() {
            self.execute_ddl(&format!("INSERT INTO {qualified} ({col_list}) VALUES {}", batch.join(", "))).await?;
        }
        tracing::info!("Loaded Postgres seed: {table_name} ({total} rows)");
        Ok(total)
    }

    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()> {
        self.execute_ddl(&format!("CREATE SCHEMA IF NOT EXISTS {}", quote_ident(schema))).await
    }

    async fn table_exists(&self, schema: &str, table: &str) -> anyhow::Result<bool> {
        let row = self.client
            .query_one(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = $1 AND table_name = $2",
                &[&schema, &table],
            )
            .await
            .map_err(|e| anyhow::anyhow!("table_exists query failed: {e}"))?;
        Ok(row.try_get::<_, i64>(0).unwrap_or(0) > 0)
    }

    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize> {
        let rows = self.client.query(sql, &[]).await
            .map_err(|e| anyhow::anyhow!("Postgres test query failed: {e}"))?;
        if rows.is_empty() { return Ok(0); }
        if rows[0].columns().len() == 1 && rows[0].columns()[0].name().to_lowercase() == "failures" {
            return Ok(rows[0].try_get::<_, i64>(0).unwrap_or(0) as usize);
        }
        Ok(rows.len())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use airform_core::DbtTarget;
    use std::collections::HashMap;

    fn make_target(host: &str, port: &str, user: &str, database: &str) -> DbtTarget {
        let mut extra = HashMap::new();
        extra.insert("host".to_string(), serde_yaml::Value::String(host.to_string()));
        extra.insert("port".to_string(), serde_yaml::Value::String(port.to_string()));
        extra.insert("user".to_string(), serde_yaml::Value::String(user.to_string()));
        extra.insert("password".to_string(), serde_yaml::Value::String(String::new()));
        DbtTarget { adapter_type: "postgres".to_string(), database: Some(database.to_string()), schema: None, threads: None, extra }
    }

    #[test]
    fn test_target_fields_mapped() {
        let target = make_target("db.example.com", "5432", "analyst", "warehouse");
        let host = target.extra.get("host").and_then(|v| v.as_str()).unwrap();
        let user = target.extra.get("user").and_then(|v| v.as_str()).unwrap();
        assert_eq!(host, "db.example.com");
        assert_eq!(user, "analyst");
        assert_eq!(target.database.as_deref(), Some("warehouse"));
    }

    #[tokio::test]
    #[ignore]
    async fn test_live_execute_query() {
        let adapter = PostgresAdapter::from_env().await.unwrap();
        let result = adapter.execute_query("SELECT 1 AS n").await.unwrap();
        assert_eq!(result.columns, vec!["n"]);
    }
}
