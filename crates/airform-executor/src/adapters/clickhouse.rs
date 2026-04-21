use airform_core::Materialization;
use async_trait::async_trait;
use std::path::Path;

use crate::csv::parse_csv_line;
use crate::warehouse::{QueryResult, WarehouseAdapter};

fn bt(ident: &str) -> String {
    format!("`{}`", ident.replace('`', "``"))
}

pub struct ClickHouseAdapter {
    base_url: String,
    database: String,
    user: String,
    password: String,
}

impl ClickHouseAdapter {
    pub fn from_target(target: &airform_core::DbtTarget) -> anyhow::Result<Self> {
        let get = |key: &str| {
            target.extra.get(key).and_then(|v| v.as_str().map(String::from))
        };
        let host = get("host").unwrap_or_else(|| "localhost".to_string());
        let port = get("port").unwrap_or_else(|| "8123".to_string());
        let user = get("user").unwrap_or_else(|| "default".to_string());
        let password = get("password").unwrap_or_default();
        let database = target.database.clone()
            .or_else(|| get("database"))
            .unwrap_or_else(|| "default".to_string());

        Ok(Self {
            base_url: format!("http://{host}:{port}"),
            database,
            user,
            password,
        })
    }

    pub fn from_env() -> anyhow::Result<Self> {
        dotenvy::dotenv().ok();
        let host = std::env::var("CLICKHOUSE_HOST").unwrap_or_else(|_| "localhost".to_string());
        let port = std::env::var("CLICKHOUSE_PORT").unwrap_or_else(|_| "8123".to_string());
        let user = std::env::var("CLICKHOUSE_USER").unwrap_or_else(|_| "default".to_string());
        let password = std::env::var("CLICKHOUSE_PASSWORD").unwrap_or_default();
        let database = std::env::var("CLICKHOUSE_DATABASE").unwrap_or_else(|_| "default".to_string());
        Ok(Self { base_url: format!("http://{host}:{port}"), database, user, password })
    }

    fn send_query(&self, sql: &str) -> anyhow::Result<String> {
        let resp = ureq::post(&self.base_url)
            .set("X-ClickHouse-User", &self.user)
            .set("X-ClickHouse-Key", &self.password)
            .set("X-ClickHouse-Database", &self.database)
            .send_string(sql);

        match resp {
            Ok(r) => r.into_string().map_err(|e| anyhow::anyhow!("ClickHouse response read error: {e}")),
            Err(ureq::Error::Status(code, r)) => {
                let body = r.into_string().unwrap_or_default();
                anyhow::bail!("ClickHouse error (HTTP {code}): {body}\nSQL: {sql}")
            }
            Err(e) => anyhow::bail!("ClickHouse request error: {e}\nSQL: {sql}"),
        }
    }

    fn execute_sql(&self, sql: &str) -> anyhow::Result<QueryResult> {
        let query = format!("{sql} FORMAT JSONEachRow");
        let body = self.send_query(&query)?;

        let mut columns: Vec<String> = Vec::new();
        let mut rows: Vec<Vec<serde_json::Value>> = Vec::new();

        for line in body.lines().filter(|l| !l.trim().is_empty()) {
            let obj: serde_json::Map<String, serde_json::Value> = serde_json::from_str(line)
                .map_err(|e| anyhow::anyhow!("ClickHouse JSON parse error: {e}\nLine: {line}"))?;
            if columns.is_empty() {
                columns = obj.keys().cloned().collect();
            }
            rows.push(columns.iter().map(|k| obj.get(k).cloned().unwrap_or(serde_json::Value::Null)).collect());
        }

        Ok(QueryResult { row_count: rows.len(), columns, rows })
    }

    fn execute_ddl(&self, sql: &str) -> anyhow::Result<()> {
        self.send_query(sql)?;
        Ok(())
    }

    fn count_rows(&self, schema: &str, table: &str) -> usize {
        let sql = format!("SELECT COUNT(*) AS n FROM {}.{} FORMAT JSONEachRow", bt(schema), bt(table));
        self.send_query(&sql)
            .ok()
            .and_then(|body| {
                let obj: serde_json::Value = serde_json::from_str(body.trim()).ok()?;
                obj["n"].as_u64().map(|n| n as usize)
                    .or_else(|| obj["n"].as_str().and_then(|s| s.parse().ok()))
            })
            .unwrap_or(0)
    }
}

#[async_trait]
impl WarehouseAdapter for ClickHouseAdapter {
    async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult> {
        self.execute_sql(sql)
    }

    async fn materialize(
        &self,
        schema: &str,
        table: &str,
        sql: &str,
        materialization: &Materialization,
        _unique_key: Option<&str>,
        _strategy: Option<&str>,
    ) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = format!("{}.{}", bt(schema), bt(table));

        match materialization {
            Materialization::View => {
                self.execute_ddl(&format!("DROP VIEW IF EXISTS {qualified}"))?;
                self.execute_ddl(&format!("CREATE VIEW {qualified} AS {sql}"))?;
                Ok(0)
            }
            Materialization::Table | Materialization::Incremental => {
                let exists = self.table_exists(schema, table).await?;
                if exists {
                    self.execute_ddl(&format!("DROP TABLE IF EXISTS {qualified}"))?;
                }
                self.execute_ddl(&format!(
                    "CREATE TABLE {qualified} \
                     ENGINE = MergeTree() ORDER BY tuple() \
                     AS {sql}"
                ))?;
                let count = self.count_rows(schema, table);
                tracing::info!("Created ClickHouse table: {table} ({count} rows)");
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
        _strategy: &str,
        _updated_at: Option<&str>,
        _check_cols: Option<&[String]>,
    ) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = format!("{}.{}", bt(schema), bt(table));
        let exists = self.table_exists(schema, table).await?;
        if exists {
            self.execute_ddl(&format!("DROP TABLE IF EXISTS {qualified}"))?;
        }
        self.execute_ddl(&format!(
            "CREATE TABLE {qualified} \
             ENGINE = ReplacingMergeTree() ORDER BY {quk} \
             AS SELECT *, now() AS dbt_valid_from, now() AS dbt_updated_at FROM ({sql})",
            quk = bt(unique_key)
        ))?;
        Ok(self.count_rows(schema, table))
    }

    async fn load_seed(&self, table_name: &str, schema: &str, csv_path: &Path) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = format!("{}.{}", bt(schema), bt(table_name));
        let content = std::fs::read_to_string(csv_path)?;
        let mut lines = content.lines();
        let header = lines.next().ok_or_else(|| anyhow::anyhow!("Empty CSV"))?;
        let columns: Vec<&str> = header.split(',').map(|c| c.trim().trim_matches('"')).collect();
        let col_defs = columns.iter().map(|c| format!("{} String", bt(c))).collect::<Vec<_>>().join(", ");

        self.execute_ddl(&format!("DROP TABLE IF EXISTS {qualified}"))?;
        self.execute_ddl(&format!(
            "CREATE TABLE {qualified} ({col_defs}) ENGINE = MergeTree() ORDER BY tuple()"
        ))?;

        let col_list = columns.iter().map(|c| bt(c)).collect::<Vec<_>>().join(", ");
        let mut total = 0usize;
        let mut batch: Vec<String> = Vec::new();

        for line in lines.filter(|l| !l.trim().is_empty()) {
            let values = parse_csv_line(line);
            let val_list = values.iter()
                .map(|v| if v.is_empty() || v.eq_ignore_ascii_case("null") { "NULL".to_string() }
                     else { format!("'{}'", v.replace('\'', "\\'")) })
                .collect::<Vec<_>>().join(", ");
            batch.push(format!("({val_list})"));
            total += 1;
            if batch.len() >= 500 {
                self.execute_ddl(&format!("INSERT INTO {qualified} ({col_list}) VALUES {}", batch.join(", ")))?;
                batch.clear();
            }
        }
        if !batch.is_empty() {
            self.execute_ddl(&format!("INSERT INTO {qualified} ({col_list}) VALUES {}", batch.join(", ")))?;
        }
        tracing::info!("Loaded ClickHouse seed: {table_name} ({total} rows)");
        Ok(total)
    }

    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()> {
        self.execute_ddl(&format!("CREATE DATABASE IF NOT EXISTS {}", bt(schema)))
    }

    async fn table_exists(&self, schema: &str, table: &str) -> anyhow::Result<bool> {
        let sql = format!(
            "SELECT COUNT(*) AS n FROM system.tables WHERE database = '{}' AND name = '{}' FORMAT JSONEachRow",
            schema.replace('\'', "\\'"),
            table.replace('\'', "\\'"),
        );
        let body = self.send_query(&sql)?;
        let obj: serde_json::Value = serde_json::from_str(body.trim()).unwrap_or(serde_json::json!({"n": 0}));
        Ok(obj["n"].as_u64().unwrap_or(0) > 0)
    }

    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize> {
        let result = self.execute_sql(sql)?;
        if result.rows.is_empty() { return Ok(0); }
        if result.columns.len() == 1 && result.columns[0].to_lowercase() == "failures" {
            return Ok(result.rows[0].first().and_then(|v| v.as_u64()).unwrap_or(0) as usize);
        }
        Ok(result.row_count)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use airform_core::DbtTarget;
    use std::collections::HashMap;

    #[test]
    fn test_from_target_fields() {
        let mut extra = HashMap::new();
        extra.insert("host".to_string(), serde_yaml::Value::String("ch.example.com".to_string()));
        extra.insert("user".to_string(), serde_yaml::Value::String("default".to_string()));
        extra.insert("password".to_string(), serde_yaml::Value::String("secret".to_string()));
        let target = DbtTarget {
            adapter_type: "clickhouse".to_string(),
            database: Some("analytics".to_string()),
            schema: None,
            threads: None,
            extra,
        };
        let adapter = ClickHouseAdapter::from_target(&target).unwrap();
        assert!(adapter.base_url.contains("ch.example.com"));
        assert_eq!(adapter.database, "analytics");
    }

    #[tokio::test]
    #[ignore]
    async fn test_live_query() {
        let adapter = ClickHouseAdapter::from_env().unwrap();
        let result = adapter.execute_query("SELECT 1 AS n").await.unwrap();
        assert_eq!(result.columns, vec!["n"]);
    }
}
