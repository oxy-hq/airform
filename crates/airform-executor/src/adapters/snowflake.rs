use airform_core::Materialization;
use arrow_array::{Array, RecordBatch};
use arrow_array::cast::AsArray;
use arrow_cast::cast;
use arrow_schema::DataType;
use async_trait::async_trait;
use snowflake_api::{JsonResult, QueryResult as SfQueryResult, SnowflakeApi};
use std::path::Path;
use std::sync::Mutex;

use crate::warehouse::{QueryResult, WarehouseAdapter};

fn sf_ident(ident: &str) -> String {
    let upper = ident.to_uppercase();
    format!("\"{}\"", upper.replace('"', "\"\""))
}

pub struct SnowflakeAdapter {
    database: String,
    api: SnowflakeApi,
    ensured_schemas: Mutex<std::collections::HashSet<String>>,
}

impl SnowflakeAdapter {
    pub async fn from_target(target: &airform_core::DbtTarget) -> anyhow::Result<Self> {
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

        let adapter = Self::build(account, user, password, warehouse, database)?;
        adapter.init_session().await?;
        Ok(adapter)
    }

    pub async fn from_env() -> anyhow::Result<Self> {
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

        let adapter = Self::build(account, user, password, warehouse, database)?;
        adapter.init_session().await?;
        Ok(adapter)
    }

    fn build(
        account: String,
        user: String,
        password: String,
        warehouse: String,
        database: String,
    ) -> anyhow::Result<Self> {
        let api = SnowflakeApi::with_password_auth(
            &account,
            Some(&warehouse),
            Some(&database),
            None,
            &user,
            None,
            &password,
        )
        .map_err(|e| anyhow::anyhow!("Failed to create Snowflake client: {e}"))?;

        Ok(Self {
            database,
            api,
            ensured_schemas: Mutex::new(std::collections::HashSet::new()),
        })
    }

    /// Set session parameters that normalize timestamp parsing and output to
    /// match what the Python bridge configured. Without TIMESTAMP_INPUT_FORMAT =
    /// 'AUTO', seed inserts with mixed timestamp formats can fail.
    async fn init_session(&self) -> anyhow::Result<()> {
        self.execute_sql("ALTER SESSION SET TIMESTAMP_INPUT_FORMAT = 'AUTO'").await?;
        self.execute_sql(
            "ALTER SESSION SET TIMESTAMP_TZ_OUTPUT_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF3 TZHTZM'",
        )
        .await?;
        Ok(())
    }

    async fn execute_sql(&self, sql: &str) -> anyhow::Result<QueryResult> {
        let result = self
            .api
            .exec(sql)
            .await
            .map_err(|e| anyhow::anyhow!("Snowflake query error: {e}\nSQL:\n{}", &sql[..sql.len().min(200)]))?;

        match result {
            SfQueryResult::Arrow(batches) => arrow_batches_to_query_result(&batches),
            SfQueryResult::Json(value) => json_to_query_result(value),
            SfQueryResult::Empty => Ok(QueryResult { row_count: 0, columns: vec![], rows: vec![] }),
        }
    }

    fn fully_qualified(&self, schema: &str, table: &str) -> String {
        format!(
            "{}.{}.{}",
            sf_ident(&self.database),
            sf_ident(schema),
            sf_ident(table)
        )
    }

    fn parse_count(result: &QueryResult) -> usize {
        result
            .rows
            .first()
            .and_then(|r| r.first())
            .and_then(|v| v.as_str())
            .and_then(|s| s.parse::<usize>().ok())
            .unwrap_or(0)
    }
}

fn arrow_batches_to_query_result(batches: &[RecordBatch]) -> anyhow::Result<QueryResult> {
    if batches.is_empty() {
        return Ok(QueryResult { row_count: 0, columns: vec![], rows: vec![] });
    }

    let schema = batches[0].schema();
    let columns: Vec<String> = schema.fields().iter().map(|f| f.name().clone()).collect();

    let mut rows: Vec<Vec<serde_json::Value>> = Vec::new();

    for batch in batches {
        let num_rows = batch.num_rows();
        let num_cols = batch.num_columns();

        let string_cols: Vec<Vec<Option<String>>> = (0..num_cols)
            .map(|col_idx| -> anyhow::Result<Vec<Option<String>>> {
                let array = batch.column(col_idx);
                let utf8 = cast(array.as_ref(), &DataType::Utf8)
                    .map_err(|e| anyhow::anyhow!("Failed to cast column {col_idx} to Utf8: {e}"))?;
                let str_array = utf8.as_string::<i32>();
                Ok((0..num_rows)
                    .map(|row_idx| {
                        if str_array.is_null(row_idx) {
                            None
                        } else {
                            Some(str_array.value(row_idx).to_string())
                        }
                    })
                    .collect())
            })
            .collect::<anyhow::Result<_>>()?;

        for row_idx in 0..num_rows {
            let row: Vec<serde_json::Value> = (0..num_cols)
                .map(|col_idx| match &string_cols[col_idx][row_idx] {
                    Some(s) => serde_json::Value::String(s.clone()),
                    None => serde_json::Value::Null,
                })
                .collect();
            rows.push(row);
        }
    }

    let row_count = rows.len();
    Ok(QueryResult { row_count, columns, rows })
}

fn json_to_query_result(result: JsonResult) -> anyhow::Result<QueryResult> {
    let columns: Vec<String> = result.schema.iter().map(|f| f.name.clone()).collect();

    let rows_arr = result
        .value
        .as_array()
        .ok_or_else(|| anyhow::anyhow!("Unexpected JSON result shape"))?;

    let rows: Vec<Vec<serde_json::Value>> = rows_arr
        .iter()
        .map(|row| {
            if let Some(arr) = row.as_array() {
                arr.clone()
            } else {
                columns
                    .iter()
                    .map(|col| row.get(col).cloned().unwrap_or(serde_json::Value::Null))
                    .collect()
            }
        })
        .collect();

    let row_count = rows.len();
    Ok(QueryResult { row_count, columns, rows })
}

#[async_trait]
impl WarehouseAdapter for SnowflakeAdapter {
    async fn execute_query(&self, sql: &str) -> anyhow::Result<QueryResult> {
        self.execute_sql(sql).await
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
                let _ = self.execute_sql(&format!("DROP TABLE IF EXISTS {qualified}")).await;
                self.execute_sql(&format!("CREATE OR REPLACE VIEW {qualified} AS {sql}")).await?;
                tracing::info!("Created Snowflake view: {table}");
                Ok(0)
            }
            Materialization::Table => {
                let _ = self.execute_sql(&format!("DROP VIEW IF EXISTS {qualified}")).await;
                self.execute_sql(&format!("CREATE OR REPLACE TABLE {qualified} AS {sql}")).await?;
                let count_result = self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}")).await?;
                let count = Self::parse_count(&count_result);
                tracing::info!("Created Snowflake table: {table} ({count} rows)");
                Ok(count)
            }
            Materialization::Incremental => {
                let exists = self.table_exists(schema, table).await?;

                if !exists {
                    self.execute_sql(&format!("CREATE TABLE {qualified} AS {sql}")).await?;
                    let count_result = self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}")).await?;
                    let count = Self::parse_count(&count_result);
                    tracing::info!("Created Snowflake incremental table: {table} ({count} rows, initial)");
                    return Ok(count);
                }

                let strategy = strategy.unwrap_or(if unique_key.is_some() { "delete+insert" } else { "append" });

                match strategy {
                    "append" => {
                        self.execute_sql(&format!("INSERT INTO {qualified} {sql}")).await?;
                    }
                    "delete+insert" | "merge" => {
                        if let Some(key) = unique_key {
                            let qk = sf_ident(key);
                            self.execute_sql(&format!(
                                "DELETE FROM {qualified} WHERE {qk} IN (SELECT {qk} FROM ({sql}))"
                            ))
                            .await?;
                        }
                        self.execute_sql(&format!("INSERT INTO {qualified} {sql}")).await?;
                    }
                    _ => {
                        tracing::warn!("Unknown strategy '{strategy}', falling back to append");
                        self.execute_sql(&format!("INSERT INTO {qualified} {sql}")).await?;
                    }
                }

                let count_result = self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}")).await?;
                let count = Self::parse_count(&count_result);
                tracing::info!("Updated Snowflake incremental table: {table} ({count} rows, strategy={strategy})");
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
            self.execute_sql(&ddl).await?;
        } else {
            let change_condition = match strategy {
                "timestamp" => {
                    let updated_at_col = updated_at.ok_or_else(|| {
                        anyhow::anyhow!("Snapshot '{table}' with timestamp strategy requires updated_at")
                    })?;
                    let qua = sf_ident(updated_at_col);
                    format!("tgt.{qua} != src.{qua}")
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| {
                        anyhow::anyhow!("Snapshot '{table}' with check strategy requires check_cols")
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
            ))
            .await?;

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
            ))
            .await?;
        }

        let count_result = self.execute_sql(&format!("SELECT COUNT(*) FROM {qualified}")).await?;
        let count = Self::parse_count(&count_result);
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

        let content = std::fs::read_to_string(csv_path)?;
        let mut lines = content.lines();

        let header = lines
            .next()
            .ok_or_else(|| anyhow::anyhow!("Empty CSV: {}", csv_path.display()))?;
        let raw_columns: Vec<&str> = header
            .split(',')
            .map(|c| c.trim().trim_matches('"'))
            .collect();

        let mut seen = std::collections::HashMap::new();
        let columns: Vec<String> = raw_columns
            .iter()
            .map(|c| {
                let count = seen.entry(c.to_lowercase()).or_insert(0usize);
                *count += 1;
                if *count > 1 { format!("{}_{}", c, count) } else { c.to_string() }
            })
            .collect();

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

        // Infer types only for BOOLEAN and TIMESTAMP — everything else stays VARCHAR.
        // Numeric types are left as VARCHAR intentionally: seeds may contain mixed
        // values or models may expect string types, and coercing to NUMBER causes
        // type mismatch errors.
        let col_types: Vec<&str> = (0..columns.len())
            .map(|i| infer_sf_type(&data_rows, i))
            .collect();

        let col_defs = columns
            .iter()
            .zip(col_types.iter())
            .map(|(c, t)| format!("{} {}", sf_ident(c), t))
            .collect::<Vec<_>>()
            .join(", ");

        self.execute_sql(&format!("CREATE OR REPLACE TABLE {qualified} ({col_defs})")).await?;

        let col_list = columns.iter().map(|c| sf_ident(c)).collect::<Vec<_>>().join(", ");
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
                ))
                .await?;
                batch.clear();
            }
        }

        if !batch.is_empty() {
            self.execute_sql(&format!(
                "INSERT INTO {qualified} ({col_list}) VALUES {}",
                batch.join(", ")
            ))
            .await?;
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
        self.execute_sql(&format!("CREATE SCHEMA IF NOT EXISTS {}", sf_ident(schema))).await?;
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
        let result = self.execute_sql(&sql).await?;
        Ok(Self::parse_count(&result) > 0)
    }

    async fn run_test_query(&self, sql: &str) -> anyhow::Result<usize> {
        let result = self.execute_sql(sql).await?;

        if result.rows.is_empty() {
            return Ok(0);
        }

        if result.columns.len() == 1 && result.columns[0].to_lowercase() == "failures" {
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

            if self.table_exists(&schema_name, &table_name).await.unwrap_or(false) {
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
                            Some("integer") | Some("int") | Some("bigint") | Some("INT64") => "NUMBER",
                            Some("float") | Some("double") | Some("numeric") | Some("FLOAT64") | Some("NUMERIC") => "FLOAT",
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
            if let Err(e) = self.execute_sql(&sql).await {
                tracing::warn!("register_sources: failed to create {}: {}", table_name, e);
            } else {
                registered += 1;
            }
        }

        tracing::info!("Registered {} source stub tables in Snowflake", registered);
        Ok(registered)
    }
}

fn looks_like_timestamp(s: &str) -> bool {
    if s.len() < 10 {
        return false;
    }
    let b = s.as_bytes();
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

fn has_timezone(s: &str) -> bool {
    s.ends_with(" UTC")
        || s.ends_with(" GMT")
        || s.ends_with("+00:00")
        || s.ends_with("+00")
        || s.ends_with("Z")
        || {
            let bytes = s.as_bytes();
            let len = bytes.len();
            len >= 5
                && (bytes[len - 5] == b'+' || bytes[len - 5] == b'-')
                && bytes[len - 4..].iter().all(|b| b.is_ascii_digit())
        }
}

fn normalize_tz(s: &str) -> String {
    let mut result = s.to_string();

    if result.len() > 10 && result.as_bytes()[10] == b'T' {
        result.replace_range(10..11, " ");
    }

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
        let bytes = result.as_bytes();
        let len = bytes.len();
        if len >= 5 {
            let sign_pos = if bytes[len - 5] == b'+' || bytes[len - 5] == b'-' {
                Some(len - 5)
            } else if len >= 6
                && bytes[len - 5].is_ascii_digit()
                && (bytes[len - 6] == b'+' || bytes[len - 6] == b'-')
            {
                None
            } else {
                None
            };
            if let Some(pos) = sign_pos {
                if bytes[pos + 1..pos + 5].iter().all(|b| b.is_ascii_digit()) {
                    let sign = result.as_bytes()[pos] as char;
                    let hh = &result[pos + 1..pos + 3];
                    let mm = &result[pos + 3..pos + 5];
                    let base_end = if pos > 0 && bytes[pos - 1] == b' ' { pos - 1 } else { pos };
                    let base = &result[..base_end];
                    result = format!("{base} {sign}{hh}:{mm}");
                }
            }
        }
    }

    result
}

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
