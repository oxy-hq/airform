//! Parity tests: verify that airform produces the same results as dbt.
//!
//! These tests run `dbt seed && dbt run` on example projects, then run the
//! airform pipeline on the same project, and compare:
//!   1. Model counts (same number of models discovered)
//!   2. Compiled SQL (no unrendered Jinja, same refs/sources resolved)
//!   3. Row counts per model (same data produced)
//!   4. Schema resolution (seeds and models land in correct schemas)
//!
//! Requires: `dbt` and `duckdb` CLIs available on PATH.
//!
//! Run: cargo test --test test_dbt_parity -- --test-threads=1

use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Once;

use airform_compiler::Compiler;
use airform_core::Materialization;
use airform_executor::{Executor, NodeStatus};
use airform_graph::build_graph;
use airform_jinja::{DbtContext, JinjaEngine};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Check that dbt CLI is available.
fn dbt_available() -> bool {
    Command::new("dbt")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

/// Check that duckdb CLI is available.
fn duckdb_available() -> bool {
    Command::new("duckdb")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

/// Filter `dbt ls` output: dbt prints log lines (with ANSI escapes) mixed with
/// actual model names. Model names contain only [a-z0-9_].
fn parse_dbt_ls_output(stdout: &str) -> Vec<String> {
    stdout
        .lines()
        .map(|l| l.trim())
        .filter(|l| {
            !l.is_empty()
                && !l.contains('\x1b')  // ANSI escape
                && l.chars().all(|c| c.is_ascii_alphanumeric() || c == '_')
        })
        .map(|l| l.to_string())
        .collect()
}

/// Run `dbt seed && dbt run` in the given project directory.
/// Returns the path to the DuckDB database file dbt wrote to.
fn dbt_seed_and_run(project_dir: &Path) -> PathBuf {
    let seed = Command::new("dbt")
        .args(["seed"])
        .current_dir(project_dir)
        .output()
        .expect("failed to run dbt seed");
    assert!(
        seed.status.success(),
        "dbt seed failed:\nstdout: {}\nstderr: {}",
        String::from_utf8_lossy(&seed.stdout),
        String::from_utf8_lossy(&seed.stderr)
    );

    let run = Command::new("dbt")
        .args(["run"])
        .current_dir(project_dir)
        .output()
        .expect("failed to run dbt run");
    assert!(
        run.status.success(),
        "dbt run failed:\nstdout: {}\nstderr: {}",
        String::from_utf8_lossy(&run.stdout),
        String::from_utf8_lossy(&run.stderr)
    );

    // Find the DuckDB file
    let profiles = std::fs::read_to_string(project_dir.join("profiles.yml"))
        .expect("read profiles.yml");
    let db_path = profiles
        .lines()
        .find(|l| l.trim().starts_with("path:") && l.contains(".duckdb"))
        .map(|l| l.split(':').nth(1).unwrap().trim().to_string())
        .expect("no duckdb path in profiles.yml");

    project_dir.join(db_path)
}

/// Query a DuckDB database file and return rows as Vec<Vec<String>>.
fn duckdb_query(db_path: &Path, sql: &str) -> Vec<Vec<String>> {
    let output = Command::new("duckdb")
        .args([db_path.to_str().unwrap(), "-csv", "-noheader", sql])
        .output()
        .expect("failed to run duckdb");

    if !output.status.success() {
        panic!(
            "duckdb query failed: {}\nSQL: {}",
            String::from_utf8_lossy(&output.stderr),
            sql
        );
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    stdout
        .lines()
        .filter(|l| !l.is_empty())
        .map(|line| line.split(',').map(|s| s.to_string()).collect())
        .collect()
}

/// Get row count for a table in a DuckDB database.
fn duckdb_row_count(db_path: &Path, schema: &str, table: &str) -> usize {
    let sql = format!("SELECT count(*) FROM \"{}\".\"{}\"", schema, table);
    let rows = duckdb_query(db_path, &sql);
    rows.first()
        .and_then(|r| r.first())
        .and_then(|s| s.parse::<usize>().ok())
        .unwrap_or(0)
}

/// Get all table names in a schema from a DuckDB database.
fn duckdb_tables(db_path: &Path, schema: &str) -> Vec<String> {
    let sql = format!(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = '{}' ORDER BY table_name",
        schema
    );
    let rows = duckdb_query(db_path, &sql);
    rows.into_iter()
        .filter_map(|r| r.into_iter().next())
        .collect()
}

/// Run the airform pipeline: load, parse, compile, seed, execute.
async fn airform_pipeline(project_dir: &Path) -> (Executor, airform_core::Manifest) {
    let load_state = airform_loader::load(project_dir).unwrap();
    let engine = JinjaEngine::new();
    let mut manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let graph = build_graph(&manifest).unwrap();

    let target = load_state.target.as_ref().unwrap();
    let target_schema = target.schema.clone().unwrap_or_else(|| "main".to_string());
    let ctx = DbtContext {
        project_name: load_state.project.name.clone(),
        execute: false,
        target_name: "dev".to_string(),
        target_schema: target_schema.clone(),
        target_database: target.database.clone().unwrap_or_else(|| "main".to_string()),
        target_type: target.adapter_type.clone(),
        ..DbtContext::new(&load_state.project.name)
    };

    let compiler = Compiler::new(engine);
    let result = compiler.compile(&mut manifest, &graph, &ctx).unwrap();
    assert_eq!(
        result.errors.len(),
        0,
        "airform compilation errors: {:?}",
        result.errors
    );

    let executor = Executor::new(&target_schema);

    let seed_results = executor.load_seeds(&manifest).await.unwrap();
    for r in &seed_results {
        assert_eq!(
            r.status,
            NodeStatus::Success,
            "airform seed {} failed: {:?}",
            r.name,
            r.message
        );
    }

    let exec_result = executor.execute(&manifest, &graph, None).await.unwrap();
    assert_eq!(
        exec_result.error_count(),
        0,
        "airform execution errors: {:?}",
        exec_result
            .results
            .iter()
            .filter(|r| r.status == NodeStatus::Error)
            .map(|r| format!("{}: {:?}", r.name, r.message))
            .collect::<Vec<_>>()
    );

    (executor, manifest)
}

/// Query airform executor for row count of a model.
async fn airform_row_count(executor: &Executor, schema: &str, table: &str) -> usize {
    let sql = format!("SELECT count(*) as cnt FROM \"{}\".\"{}\"", schema, table);
    match executor.execute_query(&sql).await {
        Ok(batches) => batches
            .iter()
            .map(|b| {
                if b.num_rows() > 0 {
                    use datafusion::arrow::array::Int64Array;
                    let col = b.column(0);
                    let arr = col.as_any().downcast_ref::<Int64Array>().unwrap();
                    arr.value(0) as usize
                } else {
                    0
                }
            })
            .sum(),
        Err(_) => 0,
    }
}

// ---------------------------------------------------------------------------
// Ensure dbt has been run once for each project (share across tests)
// ---------------------------------------------------------------------------

static JAFFLE_DBT_ONCE: Once = Once::new();
static ECOMMERCE_DBT_ONCE: Once = Once::new();

fn ensure_jaffle_dbt() -> PathBuf {
    let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/jaffle-shop");
    JAFFLE_DBT_ONCE.call_once(|| {
        dbt_seed_and_run(&project_dir);
    });
    let profiles =
        std::fs::read_to_string(project_dir.join("profiles.yml")).expect("read profiles.yml");
    let db_path = profiles
        .lines()
        .find(|l| l.trim().starts_with("path:") && l.contains(".duckdb"))
        .map(|l| l.split(':').nth(1).unwrap().trim().to_string())
        .expect("no duckdb path in profiles.yml");
    project_dir.join(db_path)
}

fn ensure_ecommerce_dbt() -> PathBuf {
    let project_dir =
        PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/ecommerce-analytics");
    ECOMMERCE_DBT_ONCE.call_once(|| {
        dbt_seed_and_run(&project_dir);
    });
    let profiles =
        std::fs::read_to_string(project_dir.join("profiles.yml")).expect("read profiles.yml");
    let db_path = profiles
        .lines()
        .find(|l| l.trim().starts_with("path:") && l.contains(".duckdb"))
        .map(|l| l.split(':').nth(1).unwrap().trim().to_string())
        .expect("no duckdb path in profiles.yml");
    project_dir.join(db_path)
}

// ===========================================================================
// Jaffle Shop parity
// ===========================================================================

#[test]
fn test_jaffle_shop_model_count_parity() {
    if !dbt_available() {
        eprintln!("Skipping: dbt not available");
        return;
    }

    let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/jaffle-shop");

    // dbt ls
    let output = Command::new("dbt")
        .args(["ls", "--resource-type", "model", "--output", "name"])
        .current_dir(&project_dir)
        .output()
        .expect("dbt ls");
    assert!(output.status.success(), "dbt ls failed");
    let dbt_models = parse_dbt_ls_output(&String::from_utf8_lossy(&output.stdout));

    // airform
    let load_state = airform_loader::load(&project_dir).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let mut airform_models: Vec<String> = manifest.models().map(|m| m.name.clone()).collect();
    airform_models.sort();

    let mut dbt_sorted = dbt_models.clone();
    dbt_sorted.sort();

    assert_eq!(
        dbt_sorted, airform_models,
        "model list mismatch: dbt={:?}, airform={:?}",
        dbt_sorted, airform_models
    );
}

#[test]
fn test_jaffle_shop_compiled_sql_parity() {
    if !dbt_available() {
        eprintln!("Skipping: dbt not available");
        return;
    }

    let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/jaffle-shop");

    // Run dbt compile
    let compile = Command::new("dbt")
        .args(["compile"])
        .current_dir(&project_dir)
        .output()
        .expect("dbt compile");
    assert!(
        compile.status.success(),
        "dbt compile failed:\n{}",
        String::from_utf8_lossy(&compile.stderr)
    );

    // Parse dbt's manifest.json
    let manifest_path = project_dir.join("target/manifest.json");
    let manifest_json: serde_json::Value =
        serde_json::from_str(&std::fs::read_to_string(&manifest_path).unwrap()).unwrap();

    let dbt_compiled: HashMap<String, String> = manifest_json["nodes"]
        .as_object()
        .unwrap()
        .iter()
        .filter(|(k, _)| k.starts_with("model."))
        .map(|(_, v)| {
            let name = v["name"].as_str().unwrap().to_string();
            let sql = v["compiled_code"].as_str().unwrap_or("").to_string();
            (name, sql)
        })
        .collect();

    // Compile with airform
    let load_state = airform_loader::load(&project_dir).unwrap();
    let engine = JinjaEngine::new();
    let mut manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let graph = build_graph(&manifest).unwrap();

    let target = load_state.target.as_ref().unwrap();
    let ctx = DbtContext {
        project_name: load_state.project.name.clone(),
        execute: false,
        target_name: "dev".to_string(),
        target_schema: target.schema.clone().unwrap_or_else(|| "main".to_string()),
        target_database: target.database.clone().unwrap_or_else(|| "main".to_string()),
        target_type: target.adapter_type.clone(),
        ..DbtContext::new(&load_state.project.name)
    };

    let compiler = Compiler::new(engine);
    compiler.compile(&mut manifest, &graph, &ctx).unwrap();

    for model in manifest.models() {
        let airform_sql = model.compiled_sql.as_ref().expect("airform compiled SQL");
        let dbt_sql = dbt_compiled
            .get(&model.name)
            .unwrap_or_else(|| panic!("dbt missing model {}", model.name));

        // No unrendered Jinja in either
        assert!(
            !airform_sql.contains("{{"),
            "airform {} has unrendered Jinja",
            model.name
        );
        assert!(
            !airform_sql.contains("{%"),
            "airform {} has unrendered Jinja blocks",
            model.name
        );
        assert!(
            !dbt_sql.contains("{{"),
            "dbt {} has unrendered Jinja",
            model.name
        );

        // Same source table references resolved
        for source_table in &["raw_customers", "raw_orders", "raw_payments"] {
            if dbt_sql.contains(source_table) {
                assert!(
                    airform_sql.contains(source_table),
                    "airform {} missing source ref to {}",
                    model.name,
                    source_table
                );
            }
        }

        // Same ref() targets resolved
        for ref_name in &["stg_customers", "stg_orders", "stg_payments"] {
            if dbt_sql.contains(ref_name) {
                assert!(
                    airform_sql.contains(ref_name),
                    "airform {} missing ref to {}",
                    model.name,
                    ref_name
                );
            }
        }
    }
}

#[tokio::test]
async fn test_jaffle_shop_row_count_parity() {
    if !dbt_available() || !duckdb_available() {
        eprintln!("Skipping: dbt or duckdb not available");
        return;
    }

    let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/jaffle-shop");
    let db_path = ensure_jaffle_dbt();

    let (executor, manifest) = airform_pipeline(&project_dir).await;

    let mut mismatches = Vec::new();
    for model in manifest.models() {
        if model.config.materialized == Materialization::Ephemeral {
            continue;
        }

        let dbt_count = duckdb_row_count(&db_path, "main", &model.name);
        let af_count = airform_row_count(&executor, "main", &model.name).await;

        println!("  {} — dbt: {}, airform: {}", model.name, dbt_count, af_count);

        if dbt_count != af_count {
            mismatches.push(format!(
                "{}: dbt={}, airform={}",
                model.name, dbt_count, af_count
            ));
        }
    }

    assert!(
        mismatches.is_empty(),
        "Row count mismatches:\n{}",
        mismatches.join("\n")
    );
}

#[tokio::test]
async fn test_jaffle_shop_schema_parity() {
    if !dbt_available() || !duckdb_available() {
        eprintln!("Skipping: dbt or duckdb not available");
        return;
    }

    let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/jaffle-shop");
    let db_path = ensure_jaffle_dbt();

    // Verify dbt schema layout
    let main_tables = duckdb_tables(&db_path, "main");
    let main_raw_tables = duckdb_tables(&db_path, "main_raw");

    assert!(
        main_raw_tables.contains(&"raw_customers".to_string()),
        "dbt: raw_customers should be in main_raw, found: {:?}",
        main_raw_tables
    );
    assert!(
        main_tables.contains(&"customers".to_string()),
        "dbt: customers should be in main, found: {:?}",
        main_tables
    );

    // Verify airform matches
    let (executor, manifest) = airform_pipeline(&project_dir).await;

    for model in manifest.models() {
        if model.config.materialized == Materialization::Ephemeral {
            continue;
        }
        let sql = format!("SELECT count(*) as cnt FROM \"main\".\"{}\"", model.name);
        let result = executor.execute_query(&sql).await;
        assert!(
            result.is_ok(),
            "airform: model {} not found in main schema",
            model.name
        );
    }

    // Seeds in main_raw
    let result = executor
        .execute_query("SELECT count(*) as cnt FROM \"main_raw\".\"raw_customers\"")
        .await;
    assert!(result.is_ok(), "airform: seeds should be in main_raw schema");
}

// ===========================================================================
// Ecommerce Analytics parity (includes ephemeral models)
// ===========================================================================

#[test]
fn test_ecommerce_model_count_parity() {
    if !dbt_available() {
        eprintln!("Skipping: dbt not available");
        return;
    }

    let project_dir =
        PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/ecommerce-analytics");

    let output = Command::new("dbt")
        .args(["ls", "--resource-type", "model", "--output", "name"])
        .current_dir(&project_dir)
        .output()
        .expect("dbt ls");
    assert!(output.status.success(), "dbt ls failed");
    let dbt_models = parse_dbt_ls_output(&String::from_utf8_lossy(&output.stdout));

    let load_state = airform_loader::load(&project_dir).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let mut airform_models: Vec<String> = manifest.models().map(|m| m.name.clone()).collect();
    airform_models.sort();

    let mut dbt_sorted = dbt_models.clone();
    dbt_sorted.sort();

    assert_eq!(
        dbt_sorted, airform_models,
        "model list mismatch: dbt={:?}, airform={:?}",
        dbt_sorted, airform_models
    );
}

#[tokio::test]
async fn test_ecommerce_row_count_parity() {
    if !dbt_available() || !duckdb_available() {
        eprintln!("Skipping: dbt or duckdb not available");
        return;
    }

    let project_dir =
        PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/ecommerce-analytics");
    let db_path = ensure_ecommerce_dbt();

    let (executor, manifest) = airform_pipeline(&project_dir).await;

    let mut mismatches = Vec::new();
    let mut compared = 0;
    for model in manifest.models() {
        if model.config.materialized == Materialization::Ephemeral {
            continue;
        }

        let dbt_count = duckdb_row_count(&db_path, "main", &model.name);
        let af_count = airform_row_count(&executor, "main", &model.name).await;

        println!("  {} — dbt: {}, airform: {}", model.name, dbt_count, af_count);

        if dbt_count != af_count {
            mismatches.push(format!(
                "{}: dbt={}, airform={}",
                model.name, dbt_count, af_count
            ));
        }
        compared += 1;
    }

    assert!(compared > 0, "should have compared at least one model");
    assert!(
        mismatches.is_empty(),
        "Row count mismatches:\n{}",
        mismatches.join("\n")
    );
}
