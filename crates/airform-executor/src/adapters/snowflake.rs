use airform_core::Materialization;
use async_trait::async_trait;
use std::path::Path;
use std::sync::Mutex;

use crate::warehouse::{QueryResult, WarehouseAdapter};

/// Quote an identifier for Snowflake, uppercasing it first to match
/// Snowflake's default behavior with unquoted identifiers.
fn sf_ident(ident: &str) -> String {
    let upper = ident.to_uppercase();
    format!("\"{}\"", upper.replace('"', "\"\""))
}

/// Snowflake adapter using the Python Snowflake connector for execution.
///
/// Uses a persistent Python child process running the Snowflake connector,
/// which handles authentication, connection pooling, and OCSP correctly.
/// This avoids the Snowflake REST API v1 rate limits that affect raw HTTP clients.
pub struct SnowflakeAdapter {
    #[allow(dead_code)]
    account: String,
    #[allow(dead_code)]
    warehouse: String,
    database: String,
    /// Schemas already ensured (CREATE SCHEMA IF NOT EXISTS), to avoid repeating.
    ensured_schemas: Mutex<std::collections::HashSet<String>>,
    /// Persistent Python subprocess for Snowflake queries.
    child: Mutex<std::process::Child>,
}

impl SnowflakeAdapter {
    /// Create a SnowflakeAdapter from a DbtTarget's extra fields.
    pub fn from_target(target: &airform_core::DbtTarget) -> anyhow::Result<Self> {
        let get = |key: &str| -> anyhow::Result<String> {
            target
                .extra
                .get(key)
                .and_then(|v| v.as_str().map(String::from))
                .ok_or_else(|| anyhow::anyhow!("Snowflake target missing '{key}' field"))
        };

        let account = get("account")?;
        let user = get("user")?;
        let password = get("password")?;
        let warehouse = target
            .extra
            .get("warehouse")
            .and_then(|v| v.as_str().map(String::from))
            .unwrap_or_else(|| "COMPUTE_WH".to_string());
        let database = target
            .database
            .clone()
            .unwrap_or_else(|| "AIRFORM_TEST".to_string());

        let mut child = Self::start_bridge(&account, &user, &password, &warehouse, &database)?;
        Self::wait_ready(&mut child)?;

        Ok(Self {
            account,
            warehouse,
            database,
            ensured_schemas: Mutex::new(std::collections::HashSet::new()),
            child: Mutex::new(child),
        })
    }

    /// Create from environment variables (for testing).
    pub fn from_env() -> anyhow::Result<Self> {
        dotenvy::dotenv().ok();

        let account =
            std::env::var("SNOWFLAKE_ACCOUNT").map_err(|_| anyhow::anyhow!("SNOWFLAKE_ACCOUNT not set"))?;
        let user = std::env::var("SNOWFLAKE_USER")
            .map_err(|_| anyhow::anyhow!("SNOWFLAKE_USER not set"))?;
        let password = std::env::var("SNOWFLAKE_PASSWORD")
            .map_err(|_| anyhow::anyhow!("SNOWFLAKE_PASSWORD not set"))?;
        let warehouse =
            std::env::var("SNOWFLAKE_WAREHOUSE").unwrap_or_else(|_| "COMPUTE_WH".to_string());
        let database =
            std::env::var("SNOWFLAKE_DATABASE").unwrap_or_else(|_| "AIRFORM_TEST".to_string());

        let mut child = Self::start_bridge(&account, &user, &password, &warehouse, &database)?;
        Self::wait_ready(&mut child)?;

        Ok(Self {
            account,
            warehouse,
            database,
            ensured_schemas: Mutex::new(std::collections::HashSet::new()),
            child: Mutex::new(child),
        })
    }

    /// Start the persistent Python bridge process.
    fn start_bridge(
        account: &str,
        user: &str,
        password: &str,
        warehouse: &str,
        database: &str,
    ) -> anyhow::Result<std::process::Child> {
        use std::process::{Command, Stdio};

        let python_code = r#"
import json, os, sys, traceback

try:
    import snowflake.connector
except ImportError:
    print(json.dumps({"error": "snowflake-connector-python not installed. Run: pip install snowflake-connector-python"}), flush=True)
    sys.exit(1)

conn = snowflake.connector.connect(
    account=os.environ['SNOWFLAKE_ACCOUNT'],
    user=os.environ['SNOWFLAKE_USER'],
    password=os.environ['SNOWFLAKE_PASSWORD'],
    warehouse=os.environ.get('SNOWFLAKE_WAREHOUSE', 'COMPUTE_WH'),
    database=os.environ.get('SNOWFLAKE_DATABASE', 'AIRFORM_TEST'),
)

# Enable AUTO format so Snowflake can parse various timestamp formats
cur = conn.cursor()
cur.execute("ALTER SESSION SET TIMESTAMP_INPUT_FORMAT = 'AUTO'")
cur.execute("ALTER SESSION SET TIMESTAMP_TZ_OUTPUT_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF3 TZHTZM'")
cur.close()

# Signal ready
print(json.dumps({"ready": True}), flush=True)

# Read SQL commands from stdin, one JSON line per command
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        cmd = json.loads(line)
        sql = cmd.get("sql", "")
        cur = conn.cursor()
        cur.execute(sql)

        columns = [desc[0] for desc in cur.description] if cur.description else []
        rows = []
        if cur.description:
            for row in cur.fetchall():
                rows.append([str(v) if v is not None else None for v in row])

        print(json.dumps({
            "success": True,
            "columns": columns,
            "rows": rows,
            "rowcount": len(rows),
        }), flush=True)
    except Exception as e:
        print(json.dumps({
            "success": False,
            "message": str(e),
        }), flush=True)

conn.close()
"#;

        let child = Command::new("python3")
            .args(["-c", python_code])
            .env("SNOWFLAKE_ACCOUNT", account)
            .env("SNOWFLAKE_USER", user)
            .env("SNOWFLAKE_PASSWORD", password)
            .env("SNOWFLAKE_WAREHOUSE", warehouse)
            .env("SNOWFLAKE_DATABASE", database)
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::inherit())
            .spawn()
            .map_err(|e| anyhow::anyhow!("Failed to start Python Snowflake bridge: {e}"))?;

        Ok(child)
    }

    /// Send a SQL command to the Python bridge and get the response.
    fn execute_sql(&self, sql: &str) -> anyhow::Result<serde_json::Value> {
        use std::io::{BufRead, Write};

        let mut child = self.child.lock().unwrap();

        let stdin = child
            .stdin
            .as_mut()
            .ok_or_else(|| anyhow::anyhow!("Python bridge stdin closed"))?;

        let cmd = serde_json::json!({"sql": sql});
        writeln!(stdin, "{}", cmd.to_string())
            .map_err(|e| anyhow::anyhow!("Failed to write to Python bridge: {e}"))?;

        let stdout = child
            .stdout
            .as_mut()
            .ok_or_else(|| anyhow::anyhow!("Python bridge stdout closed"))?;

        let mut reader = std::io::BufReader::new(stdout);
        let mut line = String::new();
        reader
            .read_line(&mut line)
            .map_err(|e| anyhow::anyhow!("Failed to read from Python bridge: {e}"))?;

        let resp: serde_json::Value = serde_json::from_str(&line)
            .map_err(|e| anyhow::anyhow!("Failed to parse Python bridge response: {e}\nLine: {line}"))?;

        if !resp["success"].as_bool().unwrap_or(false) {
            anyhow::bail!(
                "Snowflake query error: {}\nSQL:\n{}",
                resp["message"].as_str().unwrap_or("unknown"),
                &sql[..sql.len().min(200)]
            );
        }

        Ok(resp)
    }

    /// Wait for the bridge to signal ready.
    fn wait_ready(child: &mut std::process::Child) -> anyhow::Result<()> {
        use std::io::BufRead;

        let stdout = child
            .stdout
            .as_mut()
            .ok_or_else(|| anyhow::anyhow!("Python bridge stdout closed"))?;

        let mut reader = std::io::BufReader::new(stdout);
        let mut line = String::new();
        reader.read_line(&mut line)?;

        let resp: serde_json::Value = serde_json::from_str(&line)
            .map_err(|e| anyhow::anyhow!("Bridge startup failed: {e}\nOutput: {line}"))?;

        if resp.get("error").is_some() {
            anyhow::bail!("Bridge error: {}", resp["error"].as_str().unwrap_or("unknown"));
        }

        Ok(())
    }

    /// Returns a fully-qualified `"DATABASE"."SCHEMA"."TABLE"` identifier.
    fn fully_qualified(&self, schema: &str, table: &str) -> String {
        format!(
            "{}.{}.{}",
            sf_ident(&self.database),
            sf_ident(schema),
            sf_ident(table)
        )
    }

    /// Parse response into QueryResult.
    fn parse_response(&self, resp: &serde_json::Value) -> QueryResult {
        let columns: Vec<String> = resp["columns"]
            .as_array()
            .map(|arr| {
                arr.iter()
                    .map(|c| c.as_str().unwrap_or("?").to_string())
                    .collect()
            })
            .unwrap_or_default();

        let rows: Vec<Vec<serde_json::Value>> = resp["rows"]
            .as_array()
            .map(|arr| {
                arr.iter()
                    .map(|row| row.as_array().cloned().unwrap_or_default())
                    .collect()
            })
            .unwrap_or_default();

        let row_count = rows.len();
        QueryResult {
            row_count,
            columns,
            rows,
        }
    }

    /// Helper: parse COUNT(*) from a response.
    fn parse_count(&self, resp: &serde_json::Value) -> usize {
        resp["rows"][0][0]
            .as_str()
            .and_then(|s| s.parse::<usize>().ok())
            .unwrap_or(0)
    }
}

impl Drop for SnowflakeAdapter {
    fn drop(&mut self) {
        if let Ok(mut child) = self.child.lock() {
            // Close stdin to signal the Python process to exit
            drop(child.stdin.take());
            let _ = child.wait();
        }
    }
}

#[async_trait]
impl WarehouseAdapter for SnowflakeAdapter {
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
        let qualified = self.fully_qualified(schema, table);

        match materialization {
            Materialization::View => {
                // Drop TABLE if it exists (Snowflake can't replace TABLE with VIEW)
                let _ = self.execute_sql(&format!("DROP TABLE IF EXISTS {qualified}"));
                let ddl = format!("CREATE OR REPLACE VIEW {qualified} AS {sql}");
                self.execute_sql(&ddl)?;
                tracing::info!("Created Snowflake view: {table}");
                Ok(0)
            }
            Materialization::Table => {
                // Drop VIEW if it exists (Snowflake can't replace VIEW with TABLE)
                let _ = self.execute_sql(&format!("DROP VIEW IF EXISTS {qualified}"));
                let ddl = format!("CREATE OR REPLACE TABLE {qualified} AS {sql}");
                self.execute_sql(&ddl)?;
                let count_resp =
                    self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}"))?;
                let count = self.parse_count(&count_resp);
                tracing::info!("Created Snowflake table: {table} ({count} rows)");
                Ok(count)
            }
            Materialization::Incremental => {
                let exists = self.table_exists(schema, table).await?;

                if !exists {
                    let ddl = format!("CREATE TABLE {qualified} AS {sql}");
                    self.execute_sql(&ddl)?;
                    let count_resp =
                        self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}"))?;
                    let count = self.parse_count(&count_resp);
                    tracing::info!(
                        "Created Snowflake incremental table: {table} ({count} rows, initial)"
                    );
                    return Ok(count);
                }

                let strategy = strategy.unwrap_or(
                    if unique_key.is_some() {
                        "delete+insert"
                    } else {
                        "append"
                    },
                );

                match strategy {
                    "append" => {
                        self.execute_sql(&format!("INSERT INTO {qualified} {sql}"))?;
                    }
                    "delete+insert" | "merge" => {
                        if let Some(key) = unique_key {
                            let qk = sf_ident(key);
                            self.execute_sql(&format!(
                                "DELETE FROM {qualified} WHERE {qk} IN (SELECT {qk} FROM ({sql}))"
                            ))?;
                        }
                        self.execute_sql(&format!("INSERT INTO {qualified} {sql}"))?;
                    }
                    _ => {
                        tracing::warn!("Unknown strategy '{strategy}', falling back to append");
                        self.execute_sql(&format!("INSERT INTO {qualified} {sql}"))?;
                    }
                }

                let count_resp =
                    self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}"))?;
                let count = self.parse_count(&count_resp);
                tracing::info!(
                    "Updated Snowflake incremental table: {table} ({count} rows, strategy={strategy})"
                );
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
        self.ensure_schema(schema).await?;
        let qualified = self.fully_qualified(schema, table);
        let quk = sf_ident(unique_key);

        let exists = self.table_exists(schema, table).await?;

        if !exists {
            let ddl = format!(
                "CREATE TABLE {qualified} AS \
                 SELECT *, \
                 CURRENT_TIMESTAMP() AS dbt_valid_from, \
                 NULL::TIMESTAMP AS dbt_valid_to, \
                 CURRENT_TIMESTAMP() AS dbt_updated_at, \
                 MD5({quk}::VARCHAR || CURRENT_TIMESTAMP()::VARCHAR) AS dbt_scd_id \
                 FROM ({sql})"
            );
            self.execute_sql(&ddl)?;
        } else {
            let change_condition = match strategy {
                "timestamp" => {
                    let updated_at_col = updated_at.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{table}' with timestamp strategy requires updated_at"
                        )
                    })?;
                    let qua = sf_ident(updated_at_col);
                    format!("tgt.{qua} != src.{qua}")
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{table}' with check strategy requires check_cols"
                        )
                    })?;
                    cols.iter()
                        .map(|c| {
                            let qc = sf_ident(c);
                            format!("tgt.{qc} != src.{qc}")
                        })
                        .collect::<Vec<_>>()
                        .join(" OR ")
                }
                other => anyhow::bail!("Unknown snapshot strategy: '{other}'"),
            };

            self.execute_sql(&format!(
                "UPDATE {qualified} tgt SET dbt_valid_to = CURRENT_TIMESTAMP(), dbt_updated_at = CURRENT_TIMESTAMP() \
                 FROM ({sql}) src \
                 WHERE tgt.{quk} = src.{quk} AND tgt.dbt_valid_to IS NULL AND ({change_condition})"
            ))?;

            self.execute_sql(&format!(
                "INSERT INTO {qualified} \
                 SELECT src.*, \
                 CURRENT_TIMESTAMP() AS dbt_valid_from, \
                 NULL::TIMESTAMP AS dbt_valid_to, \
                 CURRENT_TIMESTAMP() AS dbt_updated_at, \
                 MD5(src.{quk}::VARCHAR || CURRENT_TIMESTAMP()::VARCHAR) AS dbt_scd_id \
                 FROM ({sql}) src \
                 LEFT JOIN {qualified} tgt ON tgt.{quk} = src.{quk} AND tgt.dbt_valid_to IS NULL \
                 WHERE tgt.{quk} IS NULL OR ({change_condition})"
            ))?;
        }

        let count_resp =
            self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}"))?;
        let count = self.parse_count(&count_resp);
        tracing::info!("Snapshot table (Snowflake): {table} ({count} rows)");
        Ok(count)
    }

    async fn load_seed(
        &self,
        table_name: &str,
        schema: &str,
        csv_path: &Path,
    ) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;
        let qualified = self.fully_qualified(schema, table_name);

        // Read CSV
        let content = std::fs::read_to_string(csv_path)?;
        let mut lines = content.lines();

        let header = lines
            .next()
            .ok_or_else(|| anyhow::anyhow!("Empty CSV: {}", csv_path.display()))?;
        let raw_columns: Vec<&str> = header
            .split(',')
            .map(|c| c.trim().trim_matches('"'))
            .collect();
        // Deduplicate column names by appending _2, _3, etc. for duplicates
        let mut seen = std::collections::HashMap::new();
        let columns: Vec<String> = raw_columns
            .iter()
            .map(|c| {
                let count = seen.entry(c.to_lowercase()).or_insert(0usize);
                *count += 1;
                if *count > 1 {
                    format!("{}_{}", c, count)
                } else {
                    c.to_string()
                }
            })
            .collect();

        // Collect all data rows for type inference, padding short rows to match header
        let num_cols = columns.len();
        let data_rows: Vec<Vec<String>> = lines
            .filter(|l| !l.trim().is_empty())
            .map(|l| {
                let mut row = parse_csv_line(l);
                while row.len() < num_cols {
                    row.push(String::new());
                }
                row
            })
            .collect();

        // Infer column types
        let col_types: Vec<&str> = (0..columns.len())
            .map(|i| infer_sf_type(&data_rows, i))
            .collect();

        let col_defs = columns
            .iter()
            .zip(col_types.iter())
            .map(|(c, t)| format!("{} {}", sf_ident(c), t))
            .collect::<Vec<_>>()
            .join(", ");

        self.execute_sql(&format!(
            "CREATE OR REPLACE TABLE {qualified} ({col_defs})"
        ))?;

        // Batch insert rows (500 rows per batch)
        let col_list = columns
            .iter()
            .map(|c| sf_ident(c))
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
                    } else if col_types[i] == "BOOLEAN" {
                        v.to_uppercase()
                    } else if col_types[i] == "TIMESTAMP_TZ" || col_types[i] == "TIMESTAMP" {
                        // Normalize timestamp format for Snowflake (T separator, TZ suffixes)
                        let normalized = normalize_tz(v);
                        format!("'{}'", normalized.replace('\'', "''"))
                    } else {
                        format!("'{}'", v.replace('\'', "''"))
                    }
                })
                .collect::<Vec<_>>()
                .join(", ");
            batch.push(format!("({})", value_list));

            if batch.len() >= 500 {
                self.execute_sql(&format!(
                    "INSERT INTO {qualified} ({col_list}) VALUES {}",
                    batch.join(", ")
                ))?;
                batch.clear();
            }
        }

        if !batch.is_empty() {
            self.execute_sql(&format!(
                "INSERT INTO {qualified} ({col_list}) VALUES {}",
                batch.join(", ")
            ))?;
        }

        tracing::info!("Loaded Snowflake seed: {table_name} ({total_rows} rows)");
        Ok(total_rows)
    }

    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()> {
        let key = schema.to_uppercase();
        {
            let ensured = self.ensured_schemas.lock().unwrap();
            if ensured.contains(&key) {
                return Ok(());
            }
        }
        self.execute_sql(&format!(
            "CREATE SCHEMA IF NOT EXISTS {}",
            sf_ident(schema)
        ))?;
        self.ensured_schemas.lock().unwrap().insert(key);
        Ok(())
    }

    async fn table_exists(&self, schema: &str, table: &str) -> anyhow::Result<bool> {
        let sql = format!(
            "SELECT COUNT(*) FROM {}.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '{}' AND TABLE_NAME = '{}'",
            sf_ident(&self.database),
            schema.replace('\'', "''").to_uppercase(),
            table.replace('\'', "''").to_uppercase(),
        );
        let resp = self.execute_sql(&sql)?;
        let count = self.parse_count(&resp);
        Ok(count > 0)
    }

    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize> {
        let resp = self.execute_sql(sql)?;
        let result = self.parse_response(&resp);

        if result.rows.is_empty() {
            return Ok(0);
        }

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
            let schema_name = source.schema.as_deref().unwrap_or("PUBLIC").to_string();
            let key = (schema_name.clone(), table_name.clone());

            if !seen.insert(key) {
                continue;
            }

            if self
                .table_exists(&schema_name, &table_name)
                .await
                .unwrap_or(false)
            {
                continue;
            }

            self.ensure_schema(&schema_name).await?;
            let qualified = self.fully_qualified(&schema_name, &table_name);

            let col_defs = if source.columns.is_empty() {
                format!("{} VARCHAR", sf_ident("_placeholder"))
            } else {
                source
                    .columns
                    .iter()
                    .map(|c| {
                        let dt = match c.data_type.as_deref() {
                            Some("integer") | Some("int") | Some("bigint") | Some("INT64") => {
                                "NUMBER"
                            }
                            Some("float")
                            | Some("double")
                            | Some("numeric")
                            | Some("FLOAT64")
                            | Some("NUMERIC") => "FLOAT",
                            Some("boolean") | Some("bool") => "BOOLEAN",
                            Some("date") => "DATE",
                            Some("timestamp") | Some("datetime") => "TIMESTAMP",
                            _ => "VARCHAR",
                        };
                        format!("{} {}", sf_ident(&c.name), dt)
                    })
                    .collect::<Vec<_>>()
                    .join(", ")
            };

            let sql = format!("CREATE TABLE IF NOT EXISTS {qualified} ({col_defs})");
            if let Err(e) = self.execute_sql(&sql) {
                tracing::warn!("register_sources: failed to create {}: {}", table_name, e);
            } else {
                registered += 1;
            }
        }

        tracing::info!("Registered {} source stub tables in Snowflake", registered);
        Ok(registered)
    }
}

/// Check if a string looks like a date (YYYY-MM-DD) or timestamp (YYYY-MM-DDTHH:MM:SS...).
fn looks_like_timestamp(s: &str) -> bool {
    // Must start with a 4-digit year
    if s.len() < 10 {
        return false;
    }
    let b = s.as_bytes();
    // YYYY-MM-DD
    b[0].is_ascii_digit()
        && b[1].is_ascii_digit()
        && b[2].is_ascii_digit()
        && b[3].is_ascii_digit()
        && b[4] == b'-'
        && b[5].is_ascii_digit()
        && b[6].is_ascii_digit()
        && b[7] == b'-'
        && b[8].is_ascii_digit()
        && b[9].is_ascii_digit()
}

/// Check if a timestamp string includes timezone info (e.g., "2020-11-09 14:20:56.976 UTC").
fn has_timezone(s: &str) -> bool {
    s.ends_with(" UTC")
        || s.ends_with(" GMT")
        || s.ends_with("+00:00")
        || s.ends_with("+00")
        || s.ends_with("Z")
        || {
            // Match numeric offset like " +0000", " -0500", "+0000"
            let bytes = s.as_bytes();
            let len = bytes.len();
            len >= 5
                && (bytes[len - 5] == b'+' || bytes[len - 5] == b'-')
                && bytes[len - 4..].iter().all(|b| b.is_ascii_digit())
        }
}

/// Normalize timestamp values for Snowflake compatibility.
/// Handles: T separators, UTC/GMT suffixes, Z suffix, numeric offsets.
/// e.g., "2022-03-30T10:46:11.937 +0000" → "2022-03-30 10:46:11.937 +00:00"
fn normalize_tz(s: &str) -> String {
    let mut result = s.to_string();

    // Replace ISO 8601 'T' separator with space
    if result.len() > 10 && result.as_bytes()[10] == b'T' {
        result.replace_range(10..11, " ");
    }

    // Normalize timezone suffix
    if result.ends_with(" UTC") {
        result.truncate(result.len() - 4);
        result.push_str(" +00:00");
    } else if result.ends_with(" GMT") {
        result.truncate(result.len() - 4);
        result.push_str(" +00:00");
    } else if result.ends_with("Z") && !result.ends_with("TZ") {
        result.truncate(result.len() - 1);
        result.push_str(" +00:00");
    } else {
        // Normalize numeric offset: " +0000" or "+0000" → " +00:00"
        let bytes = result.as_bytes();
        let len = bytes.len();
        if len >= 5 {
            // Check for pattern like +HHMM or -HHMM at end
            let sign_pos = if bytes[len - 5] == b'+' || bytes[len - 5] == b'-' {
                Some(len - 5)
            } else if len >= 6
                && bytes[len - 5].is_ascii_digit()
                && (bytes[len - 6] == b'+' || bytes[len - 6] == b'-')
            {
                // +HH:MM already has colon — leave it
                None
            } else {
                None
            };
            if let Some(pos) = sign_pos {
                if bytes[pos + 1..pos + 5].iter().all(|b| b.is_ascii_digit()) {
                    let sign = result.as_bytes()[pos] as char;
                    let hh = &result[pos + 1..pos + 3];
                    let mm = &result[pos + 3..pos + 5];
                    // Strip optional space before sign
                    let base_end = if pos > 0 && bytes[pos - 1] == b' ' {
                        pos - 1
                    } else {
                        pos
                    };
                    let base = &result[..base_end];
                    result = format!("{base} {sign}{hh}:{mm}");
                }
            }
        }
    }

    result
}

/// Infer a Snowflake column type from the data in a column.
///
/// Matches dbt behavior: seeds default to VARCHAR. We only detect
/// BOOLEAN and TIMESTAMP types since those require special handling
/// during INSERT (boolean literals, timestamp format normalization).
/// Numeric types are left as VARCHAR to avoid type mismatch errors
/// when seed data contains mixed values or when models expect string types.
fn infer_sf_type(rows: &[Vec<String>], col_idx: usize) -> &'static str {
    let mut all_timestamp = true;
    let mut all_bool = true;
    let mut any_has_tz = false;
    let mut has_non_null = false;

    for row in rows {
        if let Some(val) = row.get(col_idx) {
            if val.is_empty() || val.eq_ignore_ascii_case("null") {
                continue;
            }
            has_non_null = true;
            if looks_like_timestamp(val) {
                if has_timezone(val) {
                    any_has_tz = true;
                }
            } else {
                all_timestamp = false;
            }
            if !val.eq_ignore_ascii_case("true") && !val.eq_ignore_ascii_case("false") {
                all_bool = false;
            }
        }
    }

    if !has_non_null {
        return "VARCHAR";
    }
    if all_bool {
        return "BOOLEAN";
    }
    if all_timestamp {
        if any_has_tz {
            return "TIMESTAMP_TZ";
        }
        return "TIMESTAMP";
    }
    "VARCHAR"
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
