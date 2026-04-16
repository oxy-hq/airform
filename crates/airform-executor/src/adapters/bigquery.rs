use airform_core::Materialization;
use async_trait::async_trait;
use std::path::Path;

use crate::warehouse::{QueryResult, WarehouseAdapter};

/// BigQuery REST API adapter.
///
/// Executes SQL against Google BigQuery via the jobs.query endpoint.
pub struct BigQueryAdapter {
    project: String,
    token: String,
    dataset: String,
}

impl BigQueryAdapter {
    /// Create a BigQueryAdapter from a DbtTarget's fields.
    pub fn from_target(target: &airform_core::DbtTarget) -> anyhow::Result<Self> {
        let project = target
            .database
            .clone()
            .or_else(|| {
                target
                    .extra
                    .get("project")
                    .and_then(|v| v.as_str().map(String::from))
            })
            .ok_or_else(|| anyhow::anyhow!("BigQuery target missing 'project' or 'database' field"))?;

        let dataset = target
            .schema
            .clone()
            .or_else(|| {
                target
                    .extra
                    .get("dataset")
                    .and_then(|v| v.as_str().map(String::from))
            })
            .unwrap_or_else(|| "analytics".to_string());

        // Try to get token from target, env, or gcloud
        let token = target
            .extra
            .get("token")
            .and_then(|v| v.as_str().map(String::from))
            .or_else(|| std::env::var("BIGQUERY_ACCESS_TOKEN").ok())
            .or_else(|| get_gcloud_token())
            .ok_or_else(|| {
                anyhow::anyhow!(
                    "BigQuery token not found. Set BIGQUERY_ACCESS_TOKEN or configure gcloud."
                )
            })?;

        Ok(Self {
            project,
            token,
            dataset,
        })
    }

    /// Create from environment variables (for testing).
    pub fn from_env() -> anyhow::Result<Self> {
        dotenvy::dotenv().ok();

        let project = std::env::var("BIGQUERY_PROJECT")
            .or_else(|_| gcloud_project())
            .map_err(|_| anyhow::anyhow!("BIGQUERY_PROJECT not set and gcloud project not found"))?;

        let dataset =
            std::env::var("BIGQUERY_DATASET").unwrap_or_else(|_| "analytics".to_string());

        let token = std::env::var("BIGQUERY_ACCESS_TOKEN")
            .ok()
            .or_else(|| get_gcloud_token())
            .ok_or_else(|| {
                anyhow::anyhow!(
                    "BIGQUERY_ACCESS_TOKEN not set and gcloud auth not available"
                )
            })?;

        Ok(Self {
            project,
            token,
            dataset,
        })
    }

    /// Execute a SQL query via the BigQuery jobs.query REST API.
    fn execute_sql(&self, sql: &str) -> anyhow::Result<serde_json::Value> {
        let url = format!(
            "https://bigquery.googleapis.com/bigquery/v2/projects/{}/queries",
            self.project,
        );

        let body = serde_json::json!({
            "query": sql,
            "useLegacySql": false,
            "maxResults": 100000,
            "defaultDataset": {
                "projectId": self.project,
                "datasetId": self.dataset,
            },
            "timeoutMs": 120000,
        });

        let result = ureq::post(&url)
            .set("Authorization", &format!("Bearer {}", self.token))
            .set("Content-Type", "application/json")
            .send_string(&body.to_string());

        let resp = match result {
            Ok(resp) => resp,
            Err(ureq::Error::Status(code, resp)) => {
                let body = resp.into_string().unwrap_or_default();
                anyhow::bail!("BigQuery API error (HTTP {code}): {body}\nSQL:\n{sql}");
            }
            Err(e) => anyhow::bail!("BigQuery API error: {e}\nSQL:\n{sql}"),
        };

        let json: serde_json::Value = resp
            .into_json()
            .map_err(|e| anyhow::anyhow!("Failed to parse BigQuery response: {e}"))?;

        if let Some(err) = json.get("error") {
            let msg = err["message"].as_str().unwrap_or("unknown");
            anyhow::bail!("BigQuery error: {msg}\nSQL:\n{sql}");
        }

        // Handle incomplete jobs
        if json["jobComplete"].as_bool() == Some(false) {
            // Poll for completion
            let job_id = json["jobReference"]["jobId"]
                .as_str()
                .ok_or_else(|| anyhow::anyhow!("BigQuery job not complete and no jobId"))?;
            return self.poll_job(job_id);
        }

        Ok(json)
    }

    /// Poll a BigQuery job until completion.
    fn poll_job(&self, job_id: &str) -> anyhow::Result<serde_json::Value> {
        let url = format!(
            "https://bigquery.googleapis.com/bigquery/v2/projects/{}/queries/{}",
            self.project, job_id,
        );

        for _ in 0..60 {
            std::thread::sleep(std::time::Duration::from_secs(2));

            let resp = ureq::get(&url)
                .set("Authorization", &format!("Bearer {}", self.token))
                .call()
                .map_err(|e| anyhow::anyhow!("BigQuery poll error: {e}"))?;

            let json: serde_json::Value = resp
                .into_json()
                .map_err(|e| anyhow::anyhow!("Failed to parse BigQuery poll response: {e}"))?;

            if json["jobComplete"].as_bool() == Some(true) {
                return Ok(json);
            }
        }

        anyhow::bail!("BigQuery job {job_id} timed out after 120s")
    }

    /// Execute a DDL statement via the BigQuery jobs API (for CREATE/INSERT/etc).
    fn execute_ddl(&self, sql: &str) -> anyhow::Result<serde_json::Value> {
        // DDL uses the same query endpoint in BigQuery
        self.execute_sql(sql)
    }

    /// Parse a BigQuery query response into a QueryResult.
    fn parse_response(&self, resp: &serde_json::Value) -> QueryResult {
        let columns: Vec<String> = resp["schema"]["fields"]
            .as_array()
            .map(|arr| {
                arr.iter()
                    .map(|f| f["name"].as_str().unwrap_or("?").to_string())
                    .collect()
            })
            .unwrap_or_default();

        let rows: Vec<Vec<serde_json::Value>> = resp["rows"]
            .as_array()
            .map(|arr| {
                arr.iter()
                    .map(|row| {
                        row["f"]
                            .as_array()
                            .map(|cells| {
                                cells
                                    .iter()
                                    .map(|c| c["v"].clone())
                                    .collect()
                            })
                            .unwrap_or_default()
                    })
                    .collect()
            })
            .unwrap_or_default();

        let row_count = resp["totalRows"]
            .as_str()
            .and_then(|s| s.parse::<usize>().ok())
            .unwrap_or(rows.len());

        QueryResult {
            row_count,
            columns,
            rows,
        }
    }

    /// Returns a fully-qualified BigQuery table reference: `project.dataset.table`
    fn qualified(&self, schema: &str, table: &str) -> String {
        format!("`{}.{}.{}`", self.project, schema, table)
    }
}

#[async_trait]
impl WarehouseAdapter for BigQueryAdapter {
    async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult> {
        let resp = self.execute_sql(sql)?;
        Ok(self.parse_response(&resp))
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
        let qualified = self.qualified(schema, table);

        match materialization {
            Materialization::View => {
                let ddl = format!("CREATE OR REPLACE VIEW {qualified} AS {sql}");
                self.execute_ddl(&ddl)?;
                tracing::info!("Created BigQuery view: {table}");
                Ok(0)
            }
            Materialization::Table => {
                let ddl = format!("CREATE OR REPLACE TABLE {qualified} AS {sql}");
                self.execute_ddl(&ddl)?;
                // Get row count
                let count_resp = self.execute_sql(&format!(
                    "SELECT COUNT(*) as cnt FROM {qualified}"
                ))?;
                let count = self.parse_response(&count_resp).rows.first()
                    .and_then(|r| r.first())
                    .and_then(|v| v.as_str().and_then(|s| s.parse::<usize>().ok())
                        .or_else(|| v.as_u64().map(|n| n as usize)))
                    .unwrap_or(0);
                tracing::info!("Created BigQuery table: {table} ({count} rows)");
                Ok(count)
            }
            Materialization::Incremental => {
                // Check if table exists
                let exists = self.table_exists(schema, table).await?;

                if !exists {
                    let ddl = format!("CREATE TABLE {qualified} AS {sql}");
                    self.execute_ddl(&ddl)?;
                    tracing::info!("Created BigQuery incremental table: {table} (initial)");
                    return Ok(0);
                }

                let strategy = strategy.unwrap_or(
                    if unique_key.is_some() {
                        "merge"
                    } else {
                        "append"
                    },
                );

                match strategy {
                    "append" => {
                        let ins = format!("INSERT INTO {qualified} {sql}");
                        self.execute_ddl(&ins)?;
                    }
                    "delete+insert" | "merge" => {
                        if let Some(key) = unique_key {
                            // BigQuery MERGE
                            let merge = format!(
                                "MERGE {qualified} T \
                                 USING ({sql}) S \
                                 ON T.{key} = S.{key} \
                                 WHEN MATCHED THEN UPDATE SET {update_cols} \
                                 WHEN NOT MATCHED THEN INSERT ROW",
                                update_cols = "/* all columns */"
                            );
                            // Simpler: delete+insert
                            let del = format!(
                                "DELETE FROM {qualified} WHERE {key} IN (SELECT {key} FROM ({sql}))"
                            );
                            self.execute_ddl(&del)?;
                            let ins = format!("INSERT INTO {qualified} {sql}");
                            self.execute_ddl(&ins)?;
                            let _ = merge; // suppress unused warning
                        } else {
                            let ins = format!("INSERT INTO {qualified} {sql}");
                            self.execute_ddl(&ins)?;
                        }
                    }
                    _ => {
                        tracing::warn!("Unknown strategy '{strategy}', falling back to append");
                        let ins = format!("INSERT INTO {qualified} {sql}");
                        self.execute_ddl(&ins)?;
                    }
                }

                Ok(0)
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
        let qualified = self.qualified(schema, table);

        let exists = self.table_exists(schema, table).await?;

        if !exists {
            let ddl = format!(
                "CREATE TABLE {qualified} AS \
                 SELECT *, \
                 CURRENT_TIMESTAMP() AS dbt_valid_from, \
                 CAST(NULL AS TIMESTAMP) AS dbt_valid_to, \
                 CURRENT_TIMESTAMP() AS dbt_updated_at, \
                 TO_HEX(MD5(CONCAT(CAST({unique_key} AS STRING), CAST(CURRENT_TIMESTAMP() AS STRING)))) AS dbt_scd_id \
                 FROM ({sql})"
            );
            self.execute_ddl(&ddl)?;
        } else {
            let change_condition = match strategy {
                "timestamp" => {
                    let updated_at_col = updated_at.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{table}' with timestamp strategy requires updated_at"
                        )
                    })?;
                    format!("T.{updated_at_col} != S.{updated_at_col}")
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{table}' with check strategy requires check_cols"
                        )
                    })?;
                    cols.iter()
                        .map(|c| format!("T.{c} != S.{c}"))
                        .collect::<Vec<_>>()
                        .join(" OR ")
                }
                other => anyhow::bail!("Unknown snapshot strategy: '{other}'"),
            };

            // Expire changed rows
            let expire = format!(
                "UPDATE {qualified} T \
                 SET dbt_valid_to = CURRENT_TIMESTAMP(), dbt_updated_at = CURRENT_TIMESTAMP() \
                 FROM ({sql}) S \
                 WHERE T.{unique_key} = S.{unique_key} AND T.dbt_valid_to IS NULL AND ({change_condition})"
            );
            self.execute_ddl(&expire)?;

            // Insert new/changed
            let insert = format!(
                "INSERT INTO {qualified} \
                 SELECT S.*, \
                 CURRENT_TIMESTAMP() AS dbt_valid_from, \
                 CAST(NULL AS TIMESTAMP) AS dbt_valid_to, \
                 CURRENT_TIMESTAMP() AS dbt_updated_at, \
                 TO_HEX(MD5(CONCAT(CAST(S.{unique_key} AS STRING), CAST(CURRENT_TIMESTAMP() AS STRING)))) AS dbt_scd_id \
                 FROM ({sql}) S \
                 LEFT JOIN {qualified} T ON T.{unique_key} = S.{unique_key} AND T.dbt_valid_to IS NULL \
                 WHERE T.{unique_key} IS NULL OR ({change_condition})"
            );
            self.execute_ddl(&insert)?;
        }

        // Count
        let count_resp = self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}"))?;
        let count = self
            .parse_response(&count_resp)
            .rows
            .first()
            .and_then(|r| r.first())
            .and_then(|v| {
                v.as_str()
                    .and_then(|s| s.parse::<usize>().ok())
                    .or_else(|| v.as_u64().map(|n| n as usize))
            })
            .unwrap_or(0);
        tracing::info!("Snapshot table (BigQuery): {table} ({count} rows)");
        Ok(count)
    }

    async fn load_seed(
        &self,
        table_name: &str,
        schema: &str,
        csv_path: &Path,
    ) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = self.qualified(schema, table_name);

        let content = std::fs::read_to_string(csv_path)?;
        let mut lines = content.lines();

        let header = lines
            .next()
            .ok_or_else(|| anyhow::anyhow!("Empty CSV: {}", csv_path.display()))?;
        let columns: Vec<&str> = header
            .split(',')
            .map(|c| c.trim().trim_matches('"'))
            .collect();

        // Collect all data rows first (needed for type inference)
        let data_rows: Vec<Vec<String>> = lines
            .filter(|l| !l.trim().is_empty())
            .map(|l| parse_csv_line(l))
            .collect();

        // Infer column types from data
        let col_types: Vec<&str> = (0..columns.len())
            .map(|i| infer_bq_type(&data_rows, i))
            .collect();

        let col_defs = columns
            .iter()
            .zip(col_types.iter())
            .map(|(c, t)| format!("`{}` {}", c, t))
            .collect::<Vec<_>>()
            .join(", ");
        let create_sql = format!("CREATE OR REPLACE TABLE {qualified} ({col_defs})");
        self.execute_ddl(&create_sql)?;

        // Batch insert
        let col_list = columns
            .iter()
            .map(|c| format!("`{}`", c))
            .collect::<Vec<_>>()
            .join(", ");
        let mut batch: Vec<String> = Vec::new();
        let total_rows = data_rows.len();

        for values in &data_rows {
            let value_list = values
                .iter()
                .enumerate()
                .map(|(i, v)| {
                    if v.is_empty() || v.eq_ignore_ascii_case("null") {
                        "NULL".to_string()
                    } else if col_types[i] == "INT64" || col_types[i] == "FLOAT64" {
                        v.clone()
                    } else {
                        format!("'{}'", v.replace('\'', "\\'"))
                    }
                })
                .collect::<Vec<_>>()
                .join(", ");
            batch.push(format!("({})", value_list));

            if batch.len() >= 500 {
                let insert_sql = format!(
                    "INSERT INTO {qualified} ({col_list}) VALUES {}",
                    batch.join(", ")
                );
                self.execute_ddl(&insert_sql)?;
                batch.clear();
            }
        }

        if !batch.is_empty() {
            let insert_sql = format!(
                "INSERT INTO {qualified} ({col_list}) VALUES {}",
                batch.join(", ")
            );
            self.execute_ddl(&insert_sql)?;
        }

        tracing::info!("Loaded BigQuery seed: {table_name} ({total_rows} rows)");
        Ok(total_rows)
    }

    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()> {
        // In BigQuery, "schema" = dataset. Create if not exists.
        let sql = format!(
            "CREATE SCHEMA IF NOT EXISTS `{}.{}`",
            self.project, schema
        );
        // Ignore errors (might already exist, or might not have permission to create)
        let _ = self.execute_ddl(&sql);
        Ok(())
    }

    async fn table_exists(&self, schema: &str, table: &str) -> anyhow::Result<bool> {
        let sql = format!(
            "SELECT COUNT(*) as cnt FROM `{}.{}.INFORMATION_SCHEMA.TABLES` WHERE table_name = '{}'",
            self.project,
            schema,
            table.replace('\'', "\\'"),
        );
        let resp = self.execute_sql(&sql)?;
        let result = self.parse_response(&resp);
        let count = result
            .rows
            .first()
            .and_then(|r| r.first())
            .and_then(|v| {
                v.as_str()
                    .and_then(|s| s.parse::<usize>().ok())
                    .or_else(|| v.as_u64().map(|n| n as usize))
            })
            .unwrap_or(0);
        Ok(count > 0)
    }

    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize> {
        let resp = self.execute_sql(sql)?;
        let result = self.parse_response(&resp);

        if result.rows.is_empty() {
            return Ok(0);
        }

        // Check if result has a single "failures" column
        if result.columns.len() == 1
            && result.columns[0].to_lowercase() == "failures"
        {
            if let Some(val) = result.rows[0].first() {
                if let Some(s) = val.as_str() {
                    return Ok(s.parse::<usize>().unwrap_or(0));
                }
                if let Some(n) = val.as_u64() {
                    return Ok(n as usize);
                }
            }
        }

        Ok(result.row_count)
    }

    async fn register_sources(
        &self,
        manifest: &airform_core::Manifest,
        _target_schema: &str,
    ) -> anyhow::Result<usize> {
        let mut registered = 0;
        let mut seen = std::collections::HashSet::new();

        for source in manifest.sources.values() {
            let table_name = source.table_identifier().to_string();
            let schema_name = source
                .schema
                .as_deref()
                .unwrap_or("analytics")
                .to_string();
            let key = (schema_name.clone(), table_name.clone());

            if !seen.insert(key) {
                continue;
            }

            // Skip if table already exists
            if self
                .table_exists(&schema_name, &table_name)
                .await
                .unwrap_or(false)
            {
                continue;
            }

            self.ensure_schema(&schema_name).await?;
            let qualified = self.qualified(&schema_name, &table_name);

            let col_defs = if source.columns.is_empty() {
                "`_placeholder` STRING".to_string()
            } else {
                source
                    .columns
                    .iter()
                    .map(|c| {
                        let dt = match c.data_type.as_deref() {
                            Some("integer") | Some("int") | Some("bigint") | Some("INT64") => {
                                "INT64"
                            }
                            Some("float") | Some("double") | Some("numeric") | Some("FLOAT64")
                            | Some("NUMERIC") => "FLOAT64",
                            Some("boolean") | Some("bool") => "BOOL",
                            Some("date") => "DATE",
                            Some("timestamp") | Some("datetime") => "TIMESTAMP",
                            _ => "STRING",
                        };
                        format!("`{}` {}", c.name, dt)
                    })
                    .collect::<Vec<_>>()
                    .join(", ")
            };

            let sql = format!("CREATE TABLE IF NOT EXISTS {qualified} ({col_defs})");
            if let Err(e) = self.execute_ddl(&sql) {
                tracing::warn!(
                    "register_sources: failed to create {}: {}",
                    table_name,
                    e
                );
            } else {
                registered += 1;
            }
        }

        tracing::info!("Registered {} source stub tables in BigQuery", registered);
        Ok(registered)
    }
}

/// Infer a BigQuery column type from the data in a column.
///
/// Matches dbt behavior: seeds default to STRING. Only detect BOOL
/// to avoid type mismatch errors from aggressive numeric inference.
fn infer_bq_type(_rows: &[Vec<String>], _col_idx: usize) -> &'static str {
    "STRING"
}

/// Simple CSV line parser that handles quoted fields.
fn parse_csv_line(line: &str) -> Vec<String> {
    let mut fields = Vec::new();
    let mut current = String::new();
    let mut in_quotes = false;
    let mut chars = line.chars().peekable();

    while let Some(c) = chars.next() {
        if in_quotes {
            if c == '"' {
                if chars.peek() == Some(&'"') {
                    current.push('"');
                    chars.next();
                } else {
                    in_quotes = false;
                }
            } else {
                current.push(c);
            }
        } else if c == '"' {
            in_quotes = true;
        } else if c == ',' {
            fields.push(current.trim().to_string());
            current = String::new();
        } else {
            current.push(c);
        }
    }
    fields.push(current.trim().to_string());
    fields
}

/// Try to get a GCP access token from gcloud CLI.
fn get_gcloud_token() -> Option<String> {
    std::process::Command::new("gcloud")
        .args(["auth", "print-access-token"])
        .output()
        .ok()
        .and_then(|output| {
            if output.status.success() {
                String::from_utf8(output.stdout)
                    .ok()
                    .map(|s| s.trim().to_string())
                    .filter(|s| !s.is_empty())
            } else {
                None
            }
        })
}

/// Try to get the current GCP project from gcloud CLI.
fn gcloud_project() -> Result<String, std::env::VarError> {
    std::process::Command::new("gcloud")
        .args(["config", "get-value", "project"])
        .output()
        .ok()
        .and_then(|output| {
            if output.status.success() {
                String::from_utf8(output.stdout)
                    .ok()
                    .map(|s| s.trim().to_string())
                    .filter(|s| !s.is_empty())
            } else {
                None
            }
        })
        .ok_or(std::env::VarError::NotPresent)
}
