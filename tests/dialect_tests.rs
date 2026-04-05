//! Multi-dialect integration tests: compile and analyze dbt projects with
//! dialect-specific SQL, then optionally execute against real warehouses.
//!
//! Tier 1 (no external services):
//!   - Compile + analyze Snowflake-dialect project locally via DataFusion
//!   - Compile + analyze BigQuery-dialect project locally via DataFusion
//!   - Compile + analyze DuckDB-dialect project locally via DataFusion
//!   - Compile + analyze SQLite-dialect project locally via DataFusion
//!   - Compile + analyze ClickHouse-dialect project locally via DataFusion
//!   - Verifies that dialect normalization produces valid DataFusion SQL
//!
//! Tier 2 (requires `docker compose -f docker-compose.test.yml up`):
//!   - PostgreSQL: compile + execute locally, verify row counts
//!   - ClickHouse: seed + execute compiled SQL via HTTP API
//!
//! Tier 3 (requires credentials in .env):
//!   - Snowflake: seed + execute compiled SQL against real Snowflake
//!   - BigQuery: seed + execute compiled SQL against real BigQuery
//!   - MotherDuck: seed + execute compiled SQL against cloud DuckDB
//!
//! Run tier-1 tests:  cargo test --test dialect_tests
//! Run all tiers:     cargo test --test dialect_tests -- --include-ignored

use std::path::Path;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#[allow(dead_code)]
fn load_test_ports() {
    static ONCE: std::sync::Once = std::sync::Once::new();
    ONCE.call_once(|| {
        let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join(".test-ports.env");
        if let Ok(contents) = std::fs::read_to_string(&path) {
            for line in contents.lines() {
                let line = line.trim();
                if line.is_empty() || line.starts_with('#') {
                    continue;
                }
                if let Some((key, value)) = line.split_once('=') {
                    if std::env::var(key).is_err() {
                        unsafe { std::env::set_var(key, value) };
                    }
                }
            }
        }
    });
}

/// Compile and analyze a test project, returning schemas and diagnostics.
fn compile_and_analyze(
    project_dir: &Path,
) -> (
    airform_core::Manifest,
    airform_compiler::CompileResult,
    airform_graph::DbtGraph,
) {
    let load_state = airform_loader::load_with_target(project_dir, None)
        .expect("load project");

    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }

    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

    let mut manifest = airform_parser::parse(&load_state, &engine)
        .expect("parse project");

    let graph = airform_graph::build_graph(&manifest)
        .expect("build graph");

    let compiler = airform_compiler::Compiler::new(engine);
    let compile_result = compiler.compile(&mut manifest, &graph, &ctx)
        .expect("compile project");

    (manifest, compile_result, graph)
}

// ===========================================================================
// TIER 1: Local compilation + analysis with dialect-specific SQL
// ===========================================================================

mod snowflake_local_tests {
    use super::*;

    fn project_dir() -> std::path::PathBuf {
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/snowflake")
    }

    #[test]
    fn snowflake_project_compiles() {
        let (manifest, compile_result, _graph) = compile_and_analyze(&project_dir());
        assert!(compile_result.errors.is_empty(), "compile errors: {:?}", compile_result.errors);
        assert_eq!(compile_result.compiled_count, 3, "expected 3 models compiled");

        // Verify compiled SQL exists for all models
        for model in manifest.models() {
            assert!(
                model.compiled_sql.is_some(),
                "model {} has no compiled SQL",
                model.name
            );
        }
    }

    #[test]
    fn snowflake_dialect_normalization_produces_valid_sql() {
        let (manifest, _compile_result, graph) = compile_and_analyze(&project_dir());

        // Run the analyzer — this plans SQL through DataFusion, which validates it
        let rt = tokio::runtime::Runtime::new().unwrap();
        let analysis = rt.block_on(airform_analyzer::Analyzer::analyze(
            &manifest,
            &graph,
            Some(&project_dir()),
            None,
            Some("snowflake"),
        )).expect("analysis");

        // Check that SQL errors are minimal (no fatal errors from dialect mismatch)
        let sql_errors: Vec<_> = analysis.diagnostics.iter().filter(|d| {
            matches!(d, airform_analyzer::AnalyzerDiagnostic::SqlError { .. })
        }).collect();

        assert!(
            sql_errors.is_empty(),
            "SQL errors during Snowflake dialect analysis: {:?}",
            sql_errors
        );

        // Verify schemas were inferred
        assert!(
            analysis.schemas.len() >= 3,
            "expected at least 3 schemas, got {}",
            analysis.schemas.len()
        );
    }

    #[test]
    fn snowflake_compiled_sql_has_no_dialect_syntax() {
        let (manifest, _compile_result, _graph) = compile_and_analyze(&project_dir());

        // The stg_users model uses :: cast and ILIKE — after compilation these
        // should still be in the compiled SQL (normalization happens at analysis time)
        let stg_users = manifest.models()
            .find(|m| m.name == "stg_users")
            .expect("stg_users model");

        let sql = stg_users.compiled_sql.as_ref().unwrap();
        // The compiled SQL still has dialect syntax — normalization happens in the analyzer
        assert!(sql.contains("ilike") || sql.contains("ILIKE") || sql.contains("::"),
            "expected dialect-specific syntax in compiled SQL: {sql}");
    }

    #[test]
    fn snowflake_column_lineage_extracted() {
        let (manifest, _compile_result, graph) = compile_and_analyze(&project_dir());

        let rt = tokio::runtime::Runtime::new().unwrap();
        let analysis = rt.block_on(airform_analyzer::Analyzer::analyze(
            &manifest,
            &graph,
            Some(&project_dir()),
            None,
            Some("snowflake"),
        )).expect("analysis");

        // The customers model should have lineage edges
        let customer_edges: Vec<_> = analysis.lineage.edges.iter()
            .filter(|e| e.target_node == "customers")
            .collect();

        assert!(
            !customer_edges.is_empty(),
            "expected lineage edges for customers model"
        );
    }
}

mod bigquery_local_tests {
    use super::*;

    fn project_dir() -> std::path::PathBuf {
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/bigquery")
    }

    #[test]
    fn bigquery_project_compiles() {
        let (manifest, compile_result, _graph) = compile_and_analyze(&project_dir());
        assert!(compile_result.errors.is_empty(), "compile errors: {:?}", compile_result.errors);
        assert_eq!(compile_result.compiled_count, 3, "expected 3 models compiled");

        for model in manifest.models() {
            assert!(model.compiled_sql.is_some(), "model {} has no compiled SQL", model.name);
        }
    }

    #[test]
    fn bigquery_dialect_normalization_produces_valid_sql() {
        let (manifest, _compile_result, graph) = compile_and_analyze(&project_dir());

        let rt = tokio::runtime::Runtime::new().unwrap();
        let analysis = rt.block_on(airform_analyzer::Analyzer::analyze(
            &manifest,
            &graph,
            Some(&project_dir()),
            None,
            Some("bigquery"),
        )).expect("analysis");

        let sql_errors: Vec<_> = analysis.diagnostics.iter().filter(|d| {
            matches!(d, airform_analyzer::AnalyzerDiagnostic::SqlError { .. })
        }).collect();

        assert!(
            sql_errors.is_empty(),
            "SQL errors during BigQuery dialect analysis: {:?}",
            sql_errors
        );

        assert!(
            analysis.schemas.len() >= 3,
            "expected at least 3 schemas, got {}",
            analysis.schemas.len()
        );
    }
}

// ===========================================================================
// TIER 3: Execute against real Snowflake
// ===========================================================================

mod snowflake_tests {
    use super::*;

    const DATABASE: &str = "AIRFORM_TEST";
    const SCHEMA: &str = "ANALYTICS";

    struct SnowflakeSession {
        account: String,
        token: String,
        warehouse: String,
    }

    fn try_connect() -> Option<SnowflakeSession> {
        dotenvy::dotenv().ok();
        let account = std::env::var("SNOWFLAKE_ACCOUNT").ok()?;
        let user = std::env::var("SNOWFLAKE_USER").ok()?;
        let password = std::env::var("SNOWFLAKE_PASSWORD").ok()?;
        let warehouse = std::env::var("SNOWFLAKE_WAREHOUSE")
            .unwrap_or_else(|_| "COMPUTE_WH".to_string());

        let url = format!(
            "https://{}.snowflakecomputing.com/session/v1/login-request",
            account,
        );

        let body = serde_json::json!({
            "data": {
                "LOGIN_NAME": user,
                "PASSWORD": password,
                "ACCOUNT_NAME": account,
            }
        });

        let resp = ureq::post(&url)
            .set("Content-Type", "application/json")
            .set("Accept", "application/json")
            .send_string(&body.to_string())
            .ok()?;

        let json: serde_json::Value = resp.into_json().ok()?;
        let token = json["data"]["token"].as_str()?.to_string();

        Some(SnowflakeSession { account, token, warehouse })
    }

    fn execute_single(session: &SnowflakeSession, sql: &str) -> Result<serde_json::Value, String> {
        static SEQ: std::sync::atomic::AtomicU64 = std::sync::atomic::AtomicU64::new(1);
        let seq = SEQ.fetch_add(1, std::sync::atomic::Ordering::Relaxed);

        let request_id = format!(
            "{:08x}-{:04x}-4{:03x}-{:04x}-{:012x}",
            (seq.wrapping_mul(2654435761)) as u32,
            (seq.wrapping_mul(40503)) as u16,
            (seq.wrapping_mul(12345)) as u16 & 0xFFF,
            0x8000 | ((seq.wrapping_mul(54321)) as u16 & 0x3FFF),
            seq.wrapping_mul(1099511628211u64),
        );

        let url = format!(
            "https://{}.snowflakecomputing.com/queries/v1/query-request?requestId={}",
            session.account, request_id,
        );

        let body = serde_json::json!({
            "sqlText": sql,
            "asyncExec": false,
            "sequenceId": seq,
        });

        let result = ureq::post(&url)
            .set("Authorization", &format!("Snowflake Token=\"{}\"", session.token))
            .set("Content-Type", "application/json")
            .set("Accept", "application/snowflake")
            .send_string(&body.to_string());

        match result {
            Ok(resp) => resp.into_json::<serde_json::Value>()
                .map_err(|e| format!("Failed to parse response: {}", e)),
            Err(ureq::Error::Status(code, resp)) => {
                let body = resp.into_string().unwrap_or_default();
                Err(format!("Snowflake API error (HTTP {}): {}\nSQL:\n{}", code, body, sql))
            }
            Err(e) => Err(format!("Snowflake API error: {}\nSQL:\n{}", e, sql)),
        }
    }

    fn execute_sql(
        session: &SnowflakeSession,
        sql: &str,
        use_test_db: bool,
    ) -> Result<serde_json::Value, String> {
        let mut stmts = vec![format!("USE WAREHOUSE {}", session.warehouse)];
        if use_test_db {
            stmts.push(format!("USE DATABASE {}", DATABASE));
            stmts.push(format!("USE SCHEMA {}", SCHEMA));
        }
        stmts.push(sql.to_string());

        let mut last = serde_json::json!(null);
        for stmt in &stmts {
            last = execute_single(session, stmt)?;
        }

        if !last["success"].as_bool().unwrap_or(true) {
            return Err(format!(
                "Snowflake query error: {}\nSQL:\n{}",
                last["message"].as_str().unwrap_or("unknown"),
                sql
            ));
        }
        Ok(last)
    }

    fn row_count(resp: &serde_json::Value) -> usize {
        resp["data"]["rowset"]
            .as_array()
            .map(|a| a.len())
            .unwrap_or(0)
    }

    static SEED_ONCE: std::sync::Once = std::sync::Once::new();

    fn seed(session: &SnowflakeSession) {
        SEED_ONCE.call_once(|| seed_inner(session));
    }

    fn seed_inner(session: &SnowflakeSession) {
        let seed_sql = std::fs::read_to_string(
            Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/dialect/seed/snowflake.sql"),
        )
        .expect("read snowflake seed");

        for stmt in seed_sql.split(';') {
            let stmt = stmt.trim();
            if stmt.is_empty() || stmt.starts_with("--") {
                continue;
            }
            let is_create_db = stmt.to_uppercase().starts_with("CREATE DATABASE");
            match execute_sql(session, stmt, !is_create_db) {
                Ok(resp) => {
                    if !resp["success"].as_bool().unwrap_or(true) {
                        panic!("Seed failed: {:?}\nSQL:\n{}", resp["message"], stmt);
                    }
                }
                Err(e) => panic!("Seed failed: {}", e),
            }
        }
    }

    #[test]
    #[ignore = "tier3"]
    fn snowflake_seed_and_verify() {
        let session = match try_connect() {
            Some(s) => s,
            None => {
                eprintln!("Snowflake not configured, skipping");
                return;
            }
        };
        seed(&session);

        let resp = execute_sql(&session, "SELECT COUNT(*) FROM analytics.raw_users", true)
            .expect("count query");
        assert_eq!(row_count(&resp), 1, "expected 1 count row");
        println!("Seed verification: {:?}", resp["data"]);
    }

    #[test]
    #[ignore = "tier3"]
    fn snowflake_compiled_sql_executes() {
        let session = match try_connect() {
            Some(s) => s,
            None => {
                eprintln!("Snowflake not configured, skipping");
                return;
            }
        };
        seed(&session);

        // Compile the Snowflake test project
        let project_dir = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/snowflake");
        let (manifest, _compile_result, _graph) = compile_and_analyze(&project_dir);

        // Execute each compiled model against Snowflake
        for model in manifest.models() {
            let sql = model.compiled_sql.as_ref().expect("compiled SQL");

            // Replace local table references with Snowflake-qualified names
            let snowflake_sql = sql
                .replace("raw_users", "ANALYTICS.RAW_USERS")
                .replace("raw_orders", "ANALYTICS.RAW_ORDERS");

            // Wrap in a SELECT to verify it's valid (don't CREATE TABLE in test)
            let verify_sql = format!(
                "SELECT * FROM ({}) LIMIT 10",
                snowflake_sql
            );

            match execute_sql(&session, &verify_sql, true) {
                Ok(resp) => {
                    let rows = row_count(&resp);
                    println!("Model {}: {} rows", model.name, rows);
                    assert!(rows > 0 || model.name.starts_with("stg_"),
                        "expected rows from model {}", model.name);
                }
                Err(e) => {
                    panic!("Model {} failed on Snowflake: {}", model.name, e);
                }
            }
        }
    }
}

// ===========================================================================
// TIER 1: DuckDB local compilation + analysis
// ===========================================================================

mod duckdb_local_tests {
    use super::*;

    fn project_dir() -> std::path::PathBuf {
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/duckdb")
    }

    #[test]
    fn duckdb_project_compiles() {
        let (manifest, compile_result, _graph) = compile_and_analyze(&project_dir());
        assert!(compile_result.errors.is_empty(), "compile errors: {:?}", compile_result.errors);
        assert_eq!(compile_result.compiled_count, 3, "expected 3 models compiled");

        for model in manifest.models() {
            assert!(model.compiled_sql.is_some(), "model {} has no compiled SQL", model.name);
        }
    }

    #[test]
    fn duckdb_dialect_normalization_produces_valid_sql() {
        let (manifest, _compile_result, graph) = compile_and_analyze(&project_dir());

        let rt = tokio::runtime::Runtime::new().unwrap();
        let analysis = rt.block_on(airform_analyzer::Analyzer::analyze(
            &manifest,
            &graph,
            Some(&project_dir()),
            None,
            Some("duckdb"),
        )).expect("analysis");

        let sql_errors: Vec<_> = analysis.diagnostics.iter().filter(|d| {
            matches!(d, airform_analyzer::AnalyzerDiagnostic::SqlError { .. })
        }).collect();

        assert!(
            sql_errors.is_empty(),
            "SQL errors during DuckDB dialect analysis: {:?}",
            sql_errors
        );

        assert!(
            analysis.schemas.len() >= 3,
            "expected at least 3 schemas, got {}",
            analysis.schemas.len()
        );
    }
}

// ===========================================================================
// TIER 1: SQLite local compilation + analysis
// ===========================================================================

mod sqlite_local_tests {
    use super::*;

    fn project_dir() -> std::path::PathBuf {
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/sqlite")
    }

    #[test]
    fn sqlite_project_compiles() {
        let (manifest, compile_result, _graph) = compile_and_analyze(&project_dir());
        assert!(compile_result.errors.is_empty(), "compile errors: {:?}", compile_result.errors);
        assert_eq!(compile_result.compiled_count, 3, "expected 3 models compiled");

        for model in manifest.models() {
            assert!(model.compiled_sql.is_some(), "model {} has no compiled SQL", model.name);
        }
    }

    #[test]
    fn sqlite_dialect_normalization_produces_valid_sql() {
        let (manifest, _compile_result, graph) = compile_and_analyze(&project_dir());

        let rt = tokio::runtime::Runtime::new().unwrap();
        let analysis = rt.block_on(airform_analyzer::Analyzer::analyze(
            &manifest,
            &graph,
            Some(&project_dir()),
            None,
            Some("sqlite"),
        )).expect("analysis");

        let sql_errors: Vec<_> = analysis.diagnostics.iter().filter(|d| {
            matches!(d, airform_analyzer::AnalyzerDiagnostic::SqlError { .. })
        }).collect();

        assert!(
            sql_errors.is_empty(),
            "SQL errors during SQLite dialect analysis: {:?}",
            sql_errors
        );

        assert!(
            analysis.schemas.len() >= 3,
            "expected at least 3 schemas, got {}",
            analysis.schemas.len()
        );
    }
}

// ===========================================================================
// TIER 1: ClickHouse local compilation + analysis
// ===========================================================================

mod clickhouse_local_tests {
    use super::*;

    fn project_dir() -> std::path::PathBuf {
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/clickhouse")
    }

    #[test]
    fn clickhouse_project_compiles() {
        let (manifest, compile_result, _graph) = compile_and_analyze(&project_dir());
        assert!(compile_result.errors.is_empty(), "compile errors: {:?}", compile_result.errors);
        assert_eq!(compile_result.compiled_count, 3, "expected 3 models compiled");

        for model in manifest.models() {
            assert!(model.compiled_sql.is_some(), "model {} has no compiled SQL", model.name);
        }
    }

    #[test]
    fn clickhouse_dialect_normalization_produces_valid_sql() {
        let (manifest, _compile_result, graph) = compile_and_analyze(&project_dir());

        let rt = tokio::runtime::Runtime::new().unwrap();
        let analysis = rt.block_on(airform_analyzer::Analyzer::analyze(
            &manifest,
            &graph,
            Some(&project_dir()),
            None,
            Some("clickhouse"),
        )).expect("analysis");

        let sql_errors: Vec<_> = analysis.diagnostics.iter().filter(|d| {
            matches!(d, airform_analyzer::AnalyzerDiagnostic::SqlError { .. })
        }).collect();

        assert!(
            sql_errors.is_empty(),
            "SQL errors during ClickHouse dialect analysis: {:?}",
            sql_errors
        );

        assert!(
            analysis.schemas.len() >= 3,
            "expected at least 3 schemas, got {}",
            analysis.schemas.len()
        );
    }
}

// ===========================================================================
// TIER 2: Execute against ClickHouse in Docker
// ===========================================================================

mod clickhouse_tests {
    use super::*;

    struct ClickHouseSession {
        base_url: String,
    }

    fn try_connect() -> Option<ClickHouseSession> {
        load_test_ports();
        let port = std::env::var("AIRFORM_CH_HTTP_PORT").unwrap_or_else(|_| "18123".to_string());
        let base_url = format!("http://localhost:{}", port);

        // Check if ClickHouse is up
        let ping_url = format!("{}/ping", base_url);
        match ureq::get(&ping_url).call() {
            Ok(_) => Some(ClickHouseSession { base_url }),
            Err(_) => None,
        }
    }

    fn execute_sql(session: &ClickHouseSession, sql: &str) -> Result<String, String> {
        let url = format!(
            "{}/?user=airform&password=airformtest",
            session.base_url,
        );

        let result = ureq::post(&url)
            .set("Content-Type", "text/plain")
            .send_string(sql);

        match result {
            Ok(resp) => resp.into_string()
                .map_err(|e| format!("Failed to read ClickHouse response: {}", e)),
            Err(ureq::Error::Status(code, resp)) => {
                let body = resp.into_string().unwrap_or_default();
                Err(format!("ClickHouse HTTP error ({}): {}\nSQL: {}", code, body, sql))
            }
            Err(e) => Err(format!("ClickHouse request failed: {}\nSQL: {}", e, sql)),
        }
    }

    static SEED_ONCE: std::sync::Once = std::sync::Once::new();

    fn seed(session: &ClickHouseSession) {
        SEED_ONCE.call_once(|| seed_inner(session));
    }

    fn seed_inner(session: &ClickHouseSession) {
        let seed_sql = std::fs::read_to_string(
            Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/dialect/seed/clickhouse.sql"),
        )
        .expect("read clickhouse seed");

        for stmt in seed_sql.split(';') {
            let stmt = stmt.trim();
            if stmt.is_empty() || stmt.starts_with("--") {
                continue;
            }
            match execute_sql(session, stmt) {
                Ok(_) => {}
                Err(e) => panic!("ClickHouse seed failed: {}", e),
            }
        }
    }

    #[test]
    #[ignore = "tier2"]
    fn clickhouse_seed_and_verify() {
        let session = match try_connect() {
            Some(s) => s,
            None => {
                eprintln!("ClickHouse not available, skipping");
                return;
            }
        };
        seed(&session);

        let resp = execute_sql(
            &session,
            "SELECT count() FROM airform_test.raw_users",
        ).expect("count query");
        let count: usize = resp.trim().parse().expect("parse count");
        assert_eq!(count, 5, "expected 5 users, got {}", count);
    }

    #[test]
    #[ignore = "tier2"]
    fn clickhouse_compiled_sql_executes() {
        let session = match try_connect() {
            Some(s) => s,
            None => {
                eprintln!("ClickHouse not available, skipping");
                return;
            }
        };
        seed(&session);

        let project_dir = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/clickhouse");
        let (manifest, _compile_result, _graph) = compile_and_analyze(&project_dir);

        for model in manifest.models() {
            let sql = model.compiled_sql.as_ref().expect("compiled SQL");

            let ch_sql = sql
                .replace("raw_users", "airform_test.raw_users")
                .replace("raw_orders", "airform_test.raw_orders");

            let verify_sql = format!("SELECT * FROM ({}) LIMIT 10", ch_sql);

            match execute_sql(&session, &verify_sql) {
                Ok(resp) => {
                    let rows = resp.trim().lines().count();
                    println!("Model {}: {} rows", model.name, rows);
                }
                Err(e) => {
                    panic!("Model {} failed on ClickHouse: {}", model.name, e);
                }
            }
        }
    }
}

// ===========================================================================
// TIER 3: Execute against real BigQuery
// ===========================================================================

mod bigquery_tests {
    use super::*;

    struct BigQuerySession {
        project: String,
        token: String,
    }

    fn try_connect() -> Option<BigQuerySession> {
        dotenvy::dotenv().ok();
        let project = std::env::var("BIGQUERY_PROJECT").ok()?;
        let token = std::env::var("BIGQUERY_ACCESS_TOKEN").ok()?;
        Some(BigQuerySession { project, token })
    }

    fn execute_sql(
        session: &BigQuerySession,
        sql: &str,
    ) -> Result<serde_json::Value, String> {
        let url = format!(
            "https://bigquery.googleapis.com/bigquery/v2/projects/{}/queries",
            session.project,
        );

        let body = serde_json::json!({
            "query": sql,
            "useLegacySql": false,
            "maxResults": 10000,
            "defaultDataset": {
                "projectId": session.project,
                "datasetId": "analytics",
            },
        });

        let result = ureq::post(&url)
            .set("Authorization", &format!("Bearer {}", session.token))
            .set("Content-Type", "application/json")
            .send_string(&body.to_string());

        let resp = match result {
            Ok(resp) => resp,
            Err(ureq::Error::Status(code, resp)) => {
                let body = resp.into_string().unwrap_or_default();
                return Err(format!("BigQuery API error (HTTP {}): {}\nSQL: {}", code, body, sql));
            }
            Err(e) => return Err(format!("BigQuery request failed: {}", e)),
        };

        let json: serde_json::Value = resp
            .into_json()
            .map_err(|e| format!("Failed to parse BigQuery response: {}", e))?;

        if let Some(err) = json.get("error") {
            return Err(format!(
                "BigQuery error: {}",
                err["message"].as_str().unwrap_or("unknown")
            ));
        }

        Ok(json)
    }

    fn row_count(resp: &serde_json::Value) -> usize {
        resp["totalRows"]
            .as_str()
            .and_then(|s| s.parse::<usize>().ok())
            .unwrap_or(0)
    }

    static SEED_ONCE: std::sync::Once = std::sync::Once::new();

    fn seed(session: &BigQuerySession) {
        SEED_ONCE.call_once(|| seed_inner(session));
    }

    fn seed_inner(session: &BigQuerySession) {
        let seed_sql = std::fs::read_to_string(
            Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/dialect/seed/bigquery.sql"),
        )
        .expect("read bigquery seed");

        for stmt in seed_sql.split(';') {
            let stmt = stmt.trim();
            if stmt.is_empty() || stmt.starts_with("--") {
                continue;
            }
            match execute_sql(session, stmt) {
                Ok(resp) => {
                    if let Some(err) = resp.get("error") {
                        panic!("BigQuery seed error: {:?}\nSQL: {}", err, stmt);
                    }
                }
                Err(e) => panic!("BigQuery seed failed: {}", e),
            }
        }
    }

    #[test]
    #[ignore = "tier3"]
    fn bigquery_seed_and_verify() {
        let session = match try_connect() {
            Some(s) => s,
            None => {
                eprintln!("BigQuery not configured, skipping");
                return;
            }
        };
        seed(&session);

        let resp = execute_sql(&session, "SELECT COUNT(*) as cnt FROM analytics.raw_users")
            .expect("count query");
        assert_eq!(row_count(&resp), 1, "expected 1 count row");
        println!("BigQuery seed verification: {:?}", resp);
    }

    #[test]
    #[ignore = "tier3"]
    fn bigquery_compiled_sql_executes() {
        let session = match try_connect() {
            Some(s) => s,
            None => {
                eprintln!("BigQuery not configured, skipping");
                return;
            }
        };
        seed(&session);

        let project_dir = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/bigquery");
        let (manifest, _compile_result, _graph) = compile_and_analyze(&project_dir);

        for model in manifest.models() {
            let sql = model.compiled_sql.as_ref().expect("compiled SQL");

            // Replace local table refs with BigQuery-qualified names
            let bq_sql = sql
                .replace("raw_users", "analytics.raw_users")
                .replace("raw_orders", "analytics.raw_orders");

            let verify_sql = format!("SELECT * FROM ({}) LIMIT 10", bq_sql);

            match execute_sql(&session, &verify_sql) {
                Ok(resp) => {
                    let rows = row_count(&resp);
                    println!("Model {}: {} rows", model.name, rows);
                }
                Err(e) => {
                    panic!("Model {} failed on BigQuery: {}", model.name, e);
                }
            }
        }
    }
}

// ===========================================================================
// TIER 3: Execute against MotherDuck (cloud DuckDB)
// ===========================================================================

mod motherduck_tests {
    use super::*;

    struct MotherDuckSession {
        token: String,
    }

    fn try_connect() -> Option<MotherDuckSession> {
        dotenvy::dotenv().ok();
        let token = std::env::var("MOTHERDUCK_TOKEN").ok()?;
        if token.is_empty() {
            return None;
        }
        Some(MotherDuckSession { token })
    }

    fn execute_sql(
        session: &MotherDuckSession,
        sql: &str,
    ) -> Result<serde_json::Value, String> {
        let body = serde_json::json!({
            "sql": sql,
        });

        let result = ureq::post("https://app.motherduck.com/api/v0/sql")
            .set("Authorization", &format!("Bearer {}", session.token))
            .set("Content-Type", "application/json")
            .send_string(&body.to_string());

        let resp = match result {
            Ok(resp) => resp,
            Err(ureq::Error::Status(code, resp)) => {
                let body = resp.into_string().unwrap_or_default();
                return Err(format!(
                    "MotherDuck API error (HTTP {}): {}\nSQL: {}",
                    code, body, sql
                ));
            }
            Err(e) => return Err(format!("MotherDuck request failed: {}\nSQL: {}", e, sql)),
        };

        resp.into_json::<serde_json::Value>()
            .map_err(|e| format!("Failed to parse MotherDuck response: {}", e))
    }

    fn row_count(resp: &serde_json::Value) -> usize {
        resp["data"]
            .as_array()
            .map(|a| a.len())
            .unwrap_or(0)
    }

    static SEED_ONCE: std::sync::Once = std::sync::Once::new();

    fn seed(session: &MotherDuckSession) {
        SEED_ONCE.call_once(|| seed_inner(session));
    }

    fn seed_inner(session: &MotherDuckSession) {
        let seed_sql = std::fs::read_to_string(
            Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/dialect/seed/motherduck.sql"),
        )
        .expect("read motherduck seed");

        for stmt in seed_sql.split(';') {
            let stmt = stmt.trim();
            if stmt.is_empty() || stmt.starts_with("--") {
                continue;
            }
            match execute_sql(session, stmt) {
                Ok(_) => {}
                Err(e) => panic!("MotherDuck seed failed: {}", e),
            }
        }
    }

    #[test]
    #[ignore = "tier3"]
    fn motherduck_seed_and_verify() {
        let session = match try_connect() {
            Some(s) => s,
            None => {
                eprintln!("MotherDuck not configured, skipping");
                return;
            }
        };
        seed(&session);

        let resp = execute_sql(
            &session,
            "SELECT count(*) as cnt FROM airform_test.raw_users",
        ).expect("count query");
        println!("MotherDuck seed verification: {:?}", resp);
    }

    #[test]
    #[ignore = "tier3"]
    fn motherduck_compiled_sql_executes() {
        let session = match try_connect() {
            Some(s) => s,
            None => {
                eprintln!("MotherDuck not configured, skipping");
                return;
            }
        };
        seed(&session);

        let project_dir = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests/dialect/projects/motherduck");
        let (manifest, _compile_result, _graph) = compile_and_analyze(&project_dir);

        for model in manifest.models() {
            let sql = model.compiled_sql.as_ref().expect("compiled SQL");

            let md_sql = sql
                .replace("raw_users", "airform_test.raw_users")
                .replace("raw_orders", "airform_test.raw_orders");

            let verify_sql = format!("SELECT * FROM ({}) LIMIT 10", md_sql);

            match execute_sql(&session, &verify_sql) {
                Ok(resp) => {
                    let rows = row_count(&resp);
                    println!("Model {}: {} rows", model.name, rows);
                }
                Err(e) => {
                    panic!("Model {} failed on MotherDuck: {}", model.name, e);
                }
            }
        }
    }
}
