use airform_core::Materialization;
use async_trait::async_trait;
use mysql_async::prelude::*;
use std::path::Path;

use crate::csv::parse_csv_line;
use crate::warehouse::{QueryResult, WarehouseAdapter};

fn bt(ident: &str) -> String {
    format!("`{}`", ident.replace('`', "``"))
}

fn bt_qualified(schema: &str, table: &str) -> String {
    format!("{}.{}", bt(schema), bt(table))
}

pub struct MySqlAdapter {
    pool: mysql_async::Pool,
}

impl MySqlAdapter {
    pub fn from_target(target: &airform_core::DbtTarget) -> anyhow::Result<Self> {
        let get = |key: &str| {
            target.extra.get(key).and_then(|v| v.as_str().map(String::from))
        };
        let host = get("host").unwrap_or_else(|| "localhost".to_string());
        let port: u16 = get("port").and_then(|p| p.parse().ok()).unwrap_or(3306);
        let user = get("user").ok_or_else(|| anyhow::anyhow!("MySQL target missing 'user'"))?;
        let password = get("password").unwrap_or_default();
        let database = target.database.clone()
            .or_else(|| get("database"))
            .unwrap_or_else(|| "mysql".to_string());

        let url = format!("mysql://{user}:{password}@{host}:{port}/{database}");
        let pool = mysql_async::Pool::new(url.as_str());
        Ok(Self { pool })
    }

    pub fn from_env() -> anyhow::Result<Self> {
        dotenvy::dotenv().ok();
        let host = std::env::var("MYSQL_HOST").unwrap_or_else(|_| "localhost".to_string());
        let port = std::env::var("MYSQL_PORT").unwrap_or_else(|_| "3306".to_string());
        let user = std::env::var("MYSQL_USER").map_err(|_| anyhow::anyhow!("MYSQL_USER not set"))?;
        let password = std::env::var("MYSQL_PASSWORD").unwrap_or_default();
        let database = std::env::var("MYSQL_DATABASE").unwrap_or_else(|_| "mysql".to_string());
        let url = format!("mysql://{user}:{password}@{host}:{port}/{database}");
        Ok(Self { pool: mysql_async::Pool::new(url.as_str()) })
    }

    async fn get_conn(&self) -> anyhow::Result<mysql_async::Conn> {
        self.pool.get_conn().await.map_err(|e| anyhow::anyhow!("MySQL connection failed: {e}"))
    }

    async fn execute_ddl(&self, sql: &str) -> anyhow::Result<()> {
        let mut conn = self.get_conn().await?;
        conn.query_drop(sql).await
            .map_err(|e| anyhow::anyhow!("MySQL DDL failed: {e}\nSQL: {sql}"))
    }

    async fn count_rows(&self, schema: &str, table: &str) -> usize {
        let sql = format!("SELECT COUNT(*) FROM {}", bt_qualified(schema, table));
        let mut conn = match self.get_conn().await { Ok(c) => c, Err(_) => return 0 };
        conn.query_first::<u64, _>(sql).await.ok().flatten().unwrap_or(0) as usize
    }
}

fn mysql_val_to_json(val: mysql_async::Value) -> serde_json::Value {
    use mysql_async::Value::*;
    match val {
        NULL => serde_json::Value::Null,
        Bytes(b) => serde_json::Value::String(String::from_utf8_lossy(&b).into_owned()),
        Int(n) => serde_json::json!(n),
        UInt(n) => serde_json::json!(n),
        Float(f) => serde_json::json!(f),
        Double(f) => serde_json::json!(f),
        Date(y, m, d, h, mi, s, _us) => {
            serde_json::Value::String(format!("{y:04}-{m:02}-{d:02} {h:02}:{mi:02}:{s:02}"))
        }
        Time(neg, _d, h, mi, s, _us) => {
            let sign = if neg { "-" } else { "" };
            serde_json::Value::String(format!("{sign}{h:02}:{mi:02}:{s:02}"))
        }
    }
}

#[async_trait]
impl WarehouseAdapter for MySqlAdapter {
    async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult> {
        let mut conn = self.get_conn().await?;
        let result = conn.query_iter(sql).await
            .map_err(|e| anyhow::anyhow!("MySQL query failed: {e}\nSQL: {sql}"))?;

        let mut columns: Vec<String> = Vec::new();
        let mut rows: Vec<Vec<serde_json::Value>> = Vec::new();

        result.for_each_and_drop(|row| {
            if columns.is_empty() {
                columns = row.columns_ref().iter().map(|c| c.name_str().to_string()).collect();
            }
            let vals: Vec<serde_json::Value> = row.unwrap().into_iter().map(mysql_val_to_json).collect();
            rows.push(vals);
        }).await.map_err(|e| anyhow::anyhow!("MySQL result iteration failed: {e}"))?;

        Ok(QueryResult { row_count: rows.len(), columns, rows })
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
        let qualified = bt_qualified(schema, table);

        match materialization {
            Materialization::View => {
                self.execute_ddl(&format!("DROP VIEW IF EXISTS {qualified}")).await?;
                self.execute_ddl(&format!("CREATE VIEW {qualified} AS {sql}")).await?;
                Ok(0)
            }
            Materialization::Table => {
                self.execute_ddl(&format!("DROP TABLE IF EXISTS {qualified}")).await?;
                self.execute_ddl(&format!("CREATE TABLE {qualified} AS {sql}")).await?;
                Ok(self.count_rows(schema, table).await)
            }
            Materialization::Incremental => {
                let exists = self.table_exists(schema, table).await?;
                if !exists {
                    self.execute_ddl(&format!("CREATE TABLE {qualified} AS {sql}")).await?;
                    return Ok(self.count_rows(schema, table).await);
                }
                let strategy = strategy.unwrap_or(if unique_key.is_some() { "delete+insert" } else { "append" });
                match strategy {
                    "append" => self.execute_ddl(&format!("INSERT INTO {qualified} {sql}")).await?,
                    _ => {
                        if let Some(key) = unique_key {
                            self.execute_ddl(&format!(
                                "DELETE FROM {qualified} WHERE {} IN (SELECT {} FROM ({sql}) _sub)",
                                bt(key), bt(key)
                            )).await?;
                        }
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
        let qualified = bt_qualified(schema, table);
        let quk = bt(unique_key);
        let exists = self.table_exists(schema, table).await?;

        if !exists {
            self.execute_ddl(&format!(
                "CREATE TABLE {qualified} AS \
                 SELECT *, NOW() AS dbt_valid_from, NULL AS dbt_valid_to, NOW() AS dbt_updated_at \
                 FROM ({sql}) _src"
            )).await?;
        } else {
            let change_condition = match strategy {
                "timestamp" => {
                    let col = updated_at.ok_or_else(|| anyhow::anyhow!("timestamp strategy requires updated_at"))?;
                    format!("tgt.{0} != src.{0}", bt(col))
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| anyhow::anyhow!("check strategy requires check_cols"))?;
                    cols.iter().map(|c| format!("tgt.{0} != src.{0}", bt(c))).collect::<Vec<_>>().join(" OR ")
                }
                other => anyhow::bail!("Unknown snapshot strategy: '{other}'"),
            };
            self.execute_ddl(&format!(
                "UPDATE {qualified} tgt, ({sql}) src \
                 SET tgt.dbt_valid_to = NOW(), tgt.dbt_updated_at = NOW() \
                 WHERE tgt.{quk} = src.{quk} AND tgt.dbt_valid_to IS NULL AND ({change_condition})"
            )).await?;
            self.execute_ddl(&format!(
                "INSERT INTO {qualified} \
                 SELECT src.*, NOW(), NULL, NOW() FROM ({sql}) src \
                 LEFT JOIN {qualified} tgt ON tgt.{quk} = src.{quk} AND tgt.dbt_valid_to IS NULL \
                 WHERE tgt.{quk} IS NULL OR ({change_condition})"
            )).await?;
        }
        Ok(self.count_rows(schema, table).await)
    }

    async fn load_seed(&self, table_name: &str, schema: &str, csv_path: &Path) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = bt_qualified(schema, table_name);
        let content = std::fs::read_to_string(csv_path)?;
        let mut lines = content.lines();
        let header = lines.next().ok_or_else(|| anyhow::anyhow!("Empty CSV"))?;
        let columns: Vec<&str> = header.split(',').map(|c| c.trim().trim_matches('"')).collect();
        let col_defs = columns.iter().map(|c| format!("{} TEXT", bt(c))).collect::<Vec<_>>().join(", ");
        self.execute_ddl(&format!("DROP TABLE IF EXISTS {qualified}")).await?;
        self.execute_ddl(&format!("CREATE TABLE {qualified} ({col_defs})")).await?;

        let col_list = columns.iter().map(|c| bt(c)).collect::<Vec<_>>().join(", ");
        let mut batch: Vec<String> = Vec::new();
        let mut total = 0usize;

        for line in lines.filter(|l| !l.trim().is_empty()) {
            let values = parse_csv_line(line);
            let val_list = values.iter()
                .map(|v| if v.is_empty() || v.eq_ignore_ascii_case("null") { "NULL".to_string() }
                     else { format!("'{}'", v.replace('\'', "\\'")) })
                .collect::<Vec<_>>().join(", ");
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
        tracing::info!("Loaded MySQL seed: {table_name} ({total} rows)");
        Ok(total)
    }

    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()> {
        self.execute_ddl(&format!("CREATE DATABASE IF NOT EXISTS {}", bt(schema))).await
    }

    async fn table_exists(&self, schema: &str, table: &str) -> anyhow::Result<bool> {
        let mut conn = self.get_conn().await?;
        let count: Option<u64> = conn.exec_first(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = ? AND table_name = ?",
            (schema, table),
        ).await.map_err(|e| anyhow::anyhow!("MySQL table_exists failed: {e}"))?;
        Ok(count.unwrap_or(0) > 0)
    }

    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize> {
        let result = self.execute_query(sql).await?;
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
        extra.insert("host".to_string(), serde_yaml::Value::String("db.example.com".to_string()));
        extra.insert("port".to_string(), serde_yaml::Value::String("3306".to_string()));
        extra.insert("user".to_string(), serde_yaml::Value::String("root".to_string()));
        extra.insert("password".to_string(), serde_yaml::Value::String("secret".to_string()));
        let target = DbtTarget {
            adapter_type: "mysql".to_string(),
            database: Some("mydb".to_string()),
            schema: None,
            threads: None,
            extra,
        };
        let adapter = MySqlAdapter::from_target(&target);
        assert!(adapter.is_ok());
    }

    #[tokio::test]
    #[ignore]
    async fn test_live_query() {
        let adapter = MySqlAdapter::from_env().unwrap();
        let result = adapter.execute_query("SELECT 1 AS n").await.unwrap();
        assert_eq!(result.columns, vec!["n"]);
    }
}
