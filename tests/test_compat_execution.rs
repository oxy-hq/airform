//! Execution tests against generated compat projects.
//!
//! These tests use projects assembled by `scripts/generate_compat_projects.py`
//! from 66 open-source dbt repositories. Each project includes real models,
//! macros, and seed data from the upstream repo's integration tests.
//!
//! By default, auto-detects available cloud warehouse adapters (Snowflake,
//! BigQuery) and executes against the real warehouse — no DataFusion hacks.
//! Override with AIRFORM_TEST_ADAPTER=datafusion to force local execution.
//!
//! Prerequisites:
//!   python3 scripts/generate_compat_projects.py
//!
//! Run:
//!   cargo test --test test_compat_execution -- --include-ignored

use std::path::PathBuf;

use airform_compiler::Compiler;
use airform_core::{Manifest, ManifestNode};
use airform_executor::{AdapterType, Executor, NodeStatus};
use airform_graph::build_graph;
use airform_jinja::{DbtContext, JinjaEngine};

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

fn compat_projects_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/compat-projects")
}

fn project_exists(name: &str) -> bool {
    compat_projects_dir().join(name).join("dbt_project.yml").exists()
}

/// Detect the best available adapter.
/// Priority: AIRFORM_TEST_ADAPTER env > Snowflake > BigQuery > DataFusion.
fn detect_adapter() -> AdapterType {
    if let Ok(name) = std::env::var("AIRFORM_TEST_ADAPTER") {
        return AdapterType::from_str(&name);
    }

    dotenvy::dotenv().ok();

    // Check Snowflake
    if std::env::var("SNOWFLAKE_ACCOUNT").is_ok() && std::env::var("SNOWFLAKE_USER").is_ok() {
        return AdapterType::Snowflake;
    }

    // Check BigQuery (gcloud or env var)
    if std::env::var("BIGQUERY_PROJECT").is_ok()
        || std::env::var("BIGQUERY_ACCESS_TOKEN").is_ok()
        || std::process::Command::new("gcloud")
            .args(["config", "get-value", "project"])
            .output()
            .map(|o| o.status.success())
            .unwrap_or(false)
    {
        return AdapterType::BigQuery;
    }

    AdapterType::DataFusion
}

/// Create an executor for the given adapter type and schema.
fn create_cloud_executor(
    adapter_type: &AdapterType,
    target_schema: &str,
) -> Result<Executor, String> {
    match adapter_type {
        AdapterType::Snowflake => {
            match airform_executor::adapters::SnowflakeAdapter::from_env() {
                Ok(a) => Ok(Executor::with_adapter(Box::new(a), target_schema)),
                Err(e) => Err(format!("Snowflake adapter: {e}")),
            }
        }
        AdapterType::BigQuery => {
            match airform_executor::adapters::BigQueryAdapter::from_env() {
                Ok(a) => Ok(Executor::with_adapter(Box::new(a), target_schema)),
                Err(e) => Err(format!("BigQuery adapter: {e}")),
            }
        }
        _ => Ok(Executor::new(target_schema)),
    }
}

/// Map an adapter type to the target_type string used during compilation.
fn adapter_target_type(adapter_type: &AdapterType) -> &'static str {
    match adapter_type {
        AdapterType::Snowflake => "snowflake",
        AdapterType::BigQuery => "bigquery",
        AdapterType::DuckDb => "duckdb",
        AdapterType::Postgres => "postgres",
        AdapterType::Redshift => "redshift",
        AdapterType::Databricks => "databricks",
        _ => "datafusion",
    }
}

/// Generate a per-project schema name for isolation.
fn project_schema(adapter_type: &AdapterType, project_name: &str) -> String {
    let sanitized = project_name.replace('-', "_").replace('.', "_");
    match adapter_type {
        AdapterType::Snowflake => format!("AIRFORM_{}", sanitized.to_uppercase()),
        AdapterType::BigQuery => format!("airform_{}", sanitized.to_lowercase()),
        _ => "main".to_string(),
    }
}

/// Check if a project has source dependencies not backed by seeds.
/// Returns (total_sources, unsatisfied_sources) counts.
fn check_source_satisfaction(manifest: &Manifest) -> (usize, usize) {
    let seed_names: std::collections::HashSet<String> = manifest
        .nodes
        .values()
        .filter_map(|n| match n {
            ManifestNode::Seed(s) => Some(s.name.clone()),
            _ => None,
        })
        .collect();

    let mut seen = std::collections::HashSet::new();
    let mut total = 0;
    let mut unsatisfied = 0;

    for source in manifest.sources.values() {
        let table_id = source.table_identifier().to_string();
        if !seen.insert((source.source_name.clone(), table_id.clone())) {
            continue;
        }
        total += 1;
        // A source is satisfied if there's a seed with the same name as the table identifier
        if !seed_names.contains(&table_id) && !seed_names.contains(&source.name) {
            unsatisfied += 1;
        }
    }

    (total, unsatisfied)
}

/// Report from testing a single compat project.
#[derive(Debug)]
#[allow(dead_code)]
struct ProjectReport {
    name: String,
    load_ok: bool,
    parse_ok: bool,
    graph_ok: bool,
    compile_ok: bool,
    models_found: usize,
    compiled_count: usize,
    compile_errors: usize,
    seed_count: usize,
    seed_ok: bool,
    exec_success: usize,
    exec_error: usize,
    exec_skip: usize,
    skipped_reason: Option<String>,
    total_sources: usize,
    unsatisfied_sources: usize,
    errors: Vec<String>,
}

impl ProjectReport {
    fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            load_ok: false,
            parse_ok: false,
            graph_ok: false,
            compile_ok: false,
            models_found: 0,
            compiled_count: 0,
            compile_errors: 0,
            seed_count: 0,
            seed_ok: false,
            exec_success: 0,
            exec_error: 0,
            exec_skip: 0,
            skipped_reason: None,
            total_sources: 0,
            unsatisfied_sources: 0,
            errors: vec![],
        }
    }
}

/// Load, parse, compile a project with the given target adapter type.
fn compile_project_for(name: &str, adapter_type: &AdapterType) -> ProjectReport {
    let mut report = ProjectReport::new(name);
    let project_dir = compat_projects_dir().join(name);

    // Load
    let load_state = match airform_loader::load_with_target(&project_dir, None) {
        Ok(ls) => {
            report.load_ok = true;
            ls
        }
        Err(e) => {
            report.errors.push(format!("load: {}", e));
            return report;
        }
    };

    // Setup Jinja engine with macros
    let mut engine = JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String, Option<String>)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone(), m.package.clone()))
        .collect();
    engine.load_macros_with_packages(&macro_defs);

    // Parse
    let mut manifest = match airform_parser::parse(&load_state, &engine) {
        Ok(m) => {
            report.parse_ok = true;
            m
        }
        Err(e) => {
            report.errors.push(format!("parse: {}", e));
            return report;
        }
    };

    report.models_found = manifest.models().count();

    // Graph
    let graph = match build_graph(&manifest) {
        Ok(g) => {
            report.graph_ok = true;
            g
        }
        Err(e) => {
            report.errors.push(format!("graph: {}", e));
            return report;
        }
    };

    // Compile — use the target adapter type, not whatever the profile says
    let target_schema = project_schema(adapter_type, name);
    let mut ctx = DbtContext::new(&load_state.project.name);
    ctx.target_schema = target_schema;
    ctx.target_database = load_state
        .target
        .as_ref()
        .and_then(|t| t.database.clone())
        .unwrap_or_else(|| "main".to_string());
    ctx.target_type = adapter_target_type(adapter_type).to_string();
    ctx.execute = false;
    ctx.populate_vars(&load_state.project.vars);

    let compiler = Compiler::new(engine);
    match compiler.compile(&mut manifest, &graph, &ctx) {
        Ok(cr) => {
            report.compile_ok = true;
            report.compiled_count = cr.compiled_count;
            report.compile_errors = cr.errors.len();
            for e in cr.errors.iter().take(3) {
                report.errors.push(format!("compile: {:?}", e));
            }
        }
        Err(e) => {
            report.errors.push(format!("compile: {}", e));
        }
    }

    report
}

/// Backward-compatible: compile with DataFusion target.
fn compile_project(name: &str) -> ProjectReport {
    compile_project_for(name, &AdapterType::DataFusion)
}

/// Load, parse, compile, seed, and execute a project.
async fn execute_project(name: &str, adapter_type: &AdapterType) -> ProjectReport {
    let mut report = ProjectReport::new(name);
    let project_dir = compat_projects_dir().join(name);
    let target_schema = project_schema(adapter_type, name);

    // Load
    let load_state = match airform_loader::load_with_target(&project_dir, None) {
        Ok(ls) => {
            report.load_ok = true;
            ls
        }
        Err(e) => {
            report.errors.push(format!("load: {}", e));
            return report;
        }
    };

    // Setup Jinja engine
    let mut engine = JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String, Option<String>)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone(), m.package.clone()))
        .collect();
    engine.load_macros_with_packages(&macro_defs);

    // Parse
    let mut manifest = match airform_parser::parse(&load_state, &engine) {
        Ok(m) => {
            report.parse_ok = true;
            m
        }
        Err(e) => {
            report.errors.push(format!("parse: {}", e));
            return report;
        }
    };

    report.models_found = manifest.models().count();

    // Remap source schemas to target schema so sources point to where seeds are.
    // In real dbt, sources live in their own raw schema; in compat tests, seeds
    // stand in for sources and live in the project's target schema.
    for source in manifest.sources.values_mut() {
        source.schema = Some(target_schema.clone());
    }

    // Check source satisfaction — skip projects with unsatisfied source deps
    let (total_sources, unsatisfied) = check_source_satisfaction(&manifest);
    report.total_sources = total_sources;
    report.unsatisfied_sources = unsatisfied;
    if unsatisfied > 0 {
        report.skipped_reason = Some(format!(
            "{unsatisfied}/{total_sources} sources not backed by seeds"
        ));
        return report;
    }

    // Graph
    let graph = match build_graph(&manifest) {
        Ok(g) => {
            report.graph_ok = true;
            g
        }
        Err(e) => {
            report.errors.push(format!("graph: {}", e));
            return report;
        }
    };

    // Compile with the correct target adapter type
    let mut ctx = DbtContext::new(&load_state.project.name);
    ctx.target_schema = target_schema.clone();
    ctx.target_database = load_state
        .target
        .as_ref()
        .and_then(|t| t.database.clone())
        .unwrap_or_else(|| "main".to_string());
    ctx.target_type = adapter_target_type(adapter_type).to_string();
    ctx.execute = true;
    ctx.populate_vars(&load_state.project.vars);
    ctx.relation_columns = load_state.seed_columns.clone();
    // Also register source table identifiers → seed columns so that
    // get_columns_in_relation works for _tmp models that wrap sources.
    for source in manifest.sources.values() {
        let table_name = source.identifier.as_deref().unwrap_or(&source.name);
        if !ctx.relation_columns.contains_key(table_name) {
            let seed_cols = load_state.seed_columns.iter()
                .find(|(k, _)| k.eq_ignore_ascii_case(table_name))
                .map(|(_, v)| v.clone());
            if let Some(cols) = seed_cols {
                ctx.relation_columns.insert(table_name.to_string(), cols);
            }
        }
    }
    // For _tmp models (stg_<pkg>__<table>_tmp), map model name → seed columns.
    // These models wrap source tables; get_columns_in_relation(ref('..._tmp'))
    // needs the underlying seed columns.
    {
        let model_names: Vec<String> = manifest.models().map(|m| m.name.clone()).collect();
        for model_name in &model_names {
            if model_name.ends_with("_tmp") && !ctx.relation_columns.contains_key(model_name.as_str()) {
                let stripped = model_name.strip_suffix("_tmp").unwrap_or(model_name);
                // Extract package and table from stg_<pkg>__<table>
                let (pkg, table_part) = if let Some(pos) = stripped.rfind("__") {
                    let prefix = &stripped[..pos];
                    let pkg = prefix.strip_prefix("stg_").unwrap_or(prefix);
                    (Some(pkg.to_string()), stripped[pos + 2..].to_string())
                } else {
                    let rest = stripped.strip_prefix("stg_").unwrap_or(stripped);
                    (None, rest.to_string())
                };
                // Try multiple seed name patterns
                let candidates: Vec<String> = {
                    let mut c = vec![table_part.clone()];
                    if let Some(ref pkg) = pkg {
                        c.push(format!("{}_{}_data", pkg, table_part));  // sap_tvag_data
                        c.push(format!("{}_{}", pkg, table_part));       // sap_tvag
                    }
                    c
                };
                let cols = candidates.iter()
                    .find_map(|candidate| {
                        load_state.seed_columns.iter()
                            .find(|(k, _)| k.eq_ignore_ascii_case(candidate))
                            .map(|(_, v)| v.clone())
                    })
                    .or_else(|| {
                        // Fallback: check project vars for this table name
                        // e.g., var('tvag') = 'sap_tvag_data'
                        ctx.vars.get(&table_part)
                            .and_then(|var_val| {
                                if let Some(seed_name) = var_val.as_str() {
                                    load_state.seed_columns.iter()
                                        .find(|(k, _)| k.eq_ignore_ascii_case(seed_name))
                                        .map(|(_, v)| v.clone())
                                } else {
                                    None
                                }
                            })
                    });
                if let Some(cols) = cols {
                    ctx.relation_columns.insert(model_name.clone(), cols);
                }
            }
        }
    }

    let compiler = Compiler::new(engine);
    match compiler.compile(&mut manifest, &graph, &ctx) {
        Ok(cr) => {
            report.compile_ok = true;
            report.compiled_count = cr.compiled_count;
            report.compile_errors = cr.errors.len();
        }
        Err(e) => {
            report.errors.push(format!("compile: {}", e));
            return report;
        }
    }

    if !report.compile_ok {
        return report;
    }

    // Create executor
    let executor = match create_cloud_executor(adapter_type, &target_schema) {
        Ok(e) => e,
        Err(e) => {
            report.errors.push(format!("adapter: {e}"));
            return report;
        }
    };

    // Seed
    match executor.load_seeds(&manifest).await {
        Ok(seed_results) => {
            report.seed_count = seed_results.len();
            report.seed_ok = seed_results.iter().all(|r| r.status == NodeStatus::Success);
            if !report.seed_ok {
                for r in &seed_results {
                    if r.status != NodeStatus::Success {
                        report
                            .errors
                            .push(format!("seed {}: {:?}", r.name, r.message));
                    }
                }
            }
        }
        Err(e) => {
            report.errors.push(format!("seed: {}", e));
            return report;
        }
    }

    // Execute
    match executor.execute(&manifest, &graph, None).await {
        Ok(exec_result) => {
            report.exec_success = exec_result.success_count();
            report.exec_error = exec_result.error_count();
            report.exec_skip = exec_result.skipped_count();
            for r in &exec_result.results {
                if r.status == NodeStatus::Error {
                    report
                        .errors
                        .push(format!("exec {}: {:?}", r.name, r.message));
                }
            }
        }
        Err(e) => {
            report.errors.push(format!("execute: {}", e));
        }
    }

    report
}

// ---------------------------------------------------------------------------
// Aggregate report tests
// ---------------------------------------------------------------------------

#[test]
#[ignore = "tier1: requires generated projects (python3 scripts/generate_compat_projects.py)"]
fn compat_compile_report() {
    let projects_dir = compat_projects_dir();
    if !projects_dir.exists() {
        eprintln!("No compat-projects directory. Run: python3 scripts/generate_compat_projects.py");
        return;
    }

    let mut entries: Vec<_> = std::fs::read_dir(&projects_dir)
        .unwrap()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().map(|t| t.is_dir()).unwrap_or(false))
        .filter(|e| !e.file_name().to_string_lossy().starts_with('.'))
        .collect();
    entries.sort_by_key(|e| e.file_name());

    println!(
        "\n{:<30} {:>6} {:>8} {:>6} {:>5}",
        "PROJECT", "MODELS", "COMPILED", "ERRORS", "RATE"
    );
    println!("{}", "-".repeat(65));

    let mut total_models = 0;
    let mut total_compiled = 0;
    let mut total_errors = 0;
    let mut load_pass = 0;
    let mut parse_pass = 0;
    let mut compile_pass = 0;

    for entry in &entries {
        let name = entry.file_name().to_string_lossy().to_string();
        let report = compile_project(&name);

        let rate = if report.models_found > 0 {
            format!(
                "{:.0}%",
                report.compiled_count as f64 / report.models_found as f64 * 100.0
            )
        } else {
            "N/A".to_string()
        };

        println!(
            "{:<30} {:>6} {:>8} {:>6} {:>5}",
            name, report.models_found, report.compiled_count, report.compile_errors, rate
        );

        if !report.errors.is_empty() {
            for e in report.errors.iter().take(2) {
                println!("  {}", e);
            }
        }

        total_models += report.models_found;
        total_compiled += report.compiled_count;
        total_errors += report.compile_errors;
        if report.load_ok {
            load_pass += 1;
        }
        if report.parse_ok {
            parse_pass += 1;
        }
        if report.compile_ok {
            compile_pass += 1;
        }
    }

    println!("{}", "-".repeat(65));
    println!(
        "TOTALS: {} projects, {} models found, {} compiled, {} errors",
        entries.len(),
        total_models,
        total_compiled,
        total_errors
    );
    println!(
        "PASS: load={}/{} parse={}/{} compile={}/{}",
        load_pass,
        entries.len(),
        parse_pass,
        entries.len(),
        compile_pass,
        entries.len()
    );
    println!(
        "COMPILE RATE: {:.1}%",
        if total_models > 0 {
            total_compiled as f64 / total_models as f64 * 100.0
        } else {
            0.0
        }
    );
}

/// Path to the cached results file.
fn results_cache_path() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("tests/compat-results.json")
}

/// Load cached results from a previous run.
fn load_cached_results() -> std::collections::HashMap<String, serde_json::Value> {
    let path = results_cache_path();
    if let Ok(data) = std::fs::read_to_string(&path) {
        if let Ok(val) = serde_json::from_str::<serde_json::Value>(&data) {
            if let Some(projects) = val.get("projects").and_then(|p| p.as_object()) {
                return projects
                    .iter()
                    .map(|(k, v)| (k.clone(), v.clone()))
                    .collect();
            }
        }
    }
    std::collections::HashMap::new()
}

/// Save results to cache.
fn save_cached_results(results: &std::collections::HashMap<String, serde_json::Value>) {
    let output = serde_json::json!({
        "timestamp": chrono::Utc::now().to_rfc3339(),
        "projects": results,
    });
    if let Ok(json) = serde_json::to_string_pretty(&output) {
        let _ = std::fs::write(results_cache_path(), json);
    }
}

/// Check if a cached result indicates the project was perfect (0 errors).
fn is_cached_perfect(cached: &serde_json::Value) -> bool {
    cached.get("exec_error").and_then(|v| v.as_u64()) == Some(0)
        && cached.get("exec_success").and_then(|v| v.as_u64()).unwrap_or(0) > 0
}

#[tokio::test]
#[ignore = "tier2: requires generated projects (python3 scripts/generate_compat_projects.py)"]
async fn compat_execution_report() {
    let projects_dir = compat_projects_dir();
    if !projects_dir.exists() {
        eprintln!("No compat-projects directory. Run: python3 scripts/generate_compat_projects.py");
        return;
    }

    let adapter_type = detect_adapter();
    let incremental = std::env::var("AIRFORM_TEST_INCREMENTAL").is_ok();
    let mut cached_results = if incremental {
        load_cached_results()
    } else {
        std::collections::HashMap::new()
    };

    let mut entries: Vec<_> = std::fs::read_dir(&projects_dir)
        .unwrap()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().map(|t| t.is_dir()).unwrap_or(false))
        .filter(|e| !e.file_name().to_string_lossy().starts_with('.'))
        .collect();
    entries.sort_by_key(|e| e.file_name());

    println!(
        "\nAdapter: {}{}",
        adapter_type,
        if incremental { " (incremental — re-testing non-perfect projects)" } else { "" }
    );
    println!(
        "{:<30} {:>6} {:>8} {:>5} {:>5} {:>5} {:>5}",
        "PROJECT", "MODELS", "COMPILED", "SEEDS", "OK", "ERR", "SKIP"
    );
    println!("{}", "-".repeat(75));

    let mut total_success = 0;
    let mut total_error = 0;
    let mut total_skip = 0;
    let mut projects_executed = 0;
    let mut projects_skipped_sources = 0;
    let mut projects_cached = 0;

    let max_projects: usize = std::env::var("AIRFORM_TEST_MAX_PROJECTS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(entries.len());
    let filter = std::env::var("AIRFORM_TEST_FILTER").ok();

    for entry in entries.iter().take(max_projects) {
        let name = entry.file_name().to_string_lossy().to_string();
        if let Some(ref f) = filter {
            if !name.contains(f.as_str()) {
                continue;
            }
        }

        // In incremental mode, skip projects that were already perfect
        if incremental {
            if let Some(cached) = cached_results.get(&name) {
                if is_cached_perfect(cached) {
                    let ok = cached.get("exec_success").and_then(|v| v.as_u64()).unwrap_or(0) as usize;
                    total_success += ok;
                    projects_cached += 1;
                    println!(
                        "{:<30} {:>6} {:>8} {:>5} {:>5} {:>5} {:>5}  (cached)",
                        name,
                        cached.get("models_found").and_then(|v| v.as_u64()).unwrap_or(0),
                        cached.get("compiled_count").and_then(|v| v.as_u64()).unwrap_or(0),
                        cached.get("seed_count").and_then(|v| v.as_u64()).unwrap_or(0),
                        ok, 0, 0,
                    );
                    continue;
                }
            }
        }

        let report = execute_project(&name, &adapter_type).await;

        // Cache the result
        cached_results.insert(name.clone(), serde_json::json!({
            "models_found": report.models_found,
            "compiled_count": report.compiled_count,
            "seed_count": report.seed_count,
            "exec_success": report.exec_success,
            "exec_error": report.exec_error,
            "exec_skip": report.exec_skip,
            "skipped_reason": report.skipped_reason,
            "errors": report.errors.iter().take(5).collect::<Vec<_>>(),
        }));

        if let Some(ref reason) = report.skipped_reason {
            println!("{:<30} SKIPPED: {}", name, reason);
            projects_skipped_sources += 1;
            continue;
        }

        println!(
            "{:<30} {:>6} {:>8} {:>5} {:>5} {:>5} {:>5}",
            name,
            report.models_found,
            report.compiled_count,
            report.seed_count,
            report.exec_success,
            report.exec_error,
            report.exec_skip
        );

        if !report.errors.is_empty() {
            for e in report.errors.iter().take(2) {
                println!("  {}", e);
            }
        }

        projects_executed += 1;
        total_success += report.exec_success;
        total_error += report.exec_error;
        total_skip += report.exec_skip;
    }

    // Save results
    save_cached_results(&cached_results);

    println!("{}", "-".repeat(75));
    if incremental && projects_cached > 0 {
        println!(
            "EXECUTED: {projects_executed} projects, {projects_cached} cached, {projects_skipped_sources} skipped"
        );
    } else {
        println!(
            "EXECUTED: {projects_executed} projects ({projects_skipped_sources} skipped — unsatisfied sources)"
        );
    }
    println!(
        "TOTALS: {} succeeded, {} errored, {} skipped",
        total_success, total_error, total_skip
    );
    if total_success + total_error > 0 {
        println!(
            "SUCCESS RATE: {:.1}%",
            total_success as f64 / (total_success + total_error) as f64 * 100.0
        );
    }
}

// ---------------------------------------------------------------------------
// Individual compile tests (tier 1) - one per repo category
// ---------------------------------------------------------------------------

macro_rules! compile_test {
    ($name:ident, $project:expr) => {
        #[test]
        #[ignore = "tier1: requires generated projects"]
        fn $name() {
            if !project_exists($project) {
                eprintln!("Skipping: {} not generated", $project);
                return;
            }
            let report = compile_project($project);
            assert!(
                report.load_ok,
                "{}: load failed: {:?}",
                $project,
                report.errors
            );
            assert!(
                report.parse_ok,
                "{}: parse failed: {:?}",
                $project,
                report.errors
            );
            assert!(
                report.models_found > 0,
                "{}: no models found",
                $project
            );
        }
    };
}

// dbt-labs examples
compile_test!(compile_jaffle_shop, "jaffle-shop");
compile_test!(compile_mrr_playbook, "mrr-playbook");
compile_test!(compile_attribution_playbook, "attribution-playbook");

// Fivetran connectors
compile_test!(compile_shopify, "shopify");
compile_test!(compile_stripe, "stripe");
compile_test!(compile_hubspot, "hubspot");
compile_test!(compile_zendesk, "zendesk");
compile_test!(compile_github, "github");
compile_test!(compile_jira, "jira");
compile_test!(compile_salesforce, "salesforce");
compile_test!(compile_netsuite, "netsuite");
compile_test!(compile_quickbooks, "quickbooks");
compile_test!(compile_google_ads, "google-ads");
compile_test!(compile_facebook_ads, "facebook-ads");
compile_test!(compile_ad_reporting, "ad-reporting");
compile_test!(compile_intercom, "intercom");
compile_test!(compile_marketo, "marketo");
compile_test!(compile_mailchimp, "mailchimp");
compile_test!(compile_asana, "asana");
compile_test!(compile_greenhouse, "greenhouse");
compile_test!(compile_lever, "lever");
compile_test!(compile_pendo, "pendo");
compile_test!(compile_iterable, "iterable");
compile_test!(compile_klaviyo, "klaviyo");
compile_test!(compile_recharge, "recharge");
compile_test!(compile_recurly, "recurly");
compile_test!(compile_xero, "xero");
compile_test!(compile_sage_intacct, "sage-intacct");
compile_test!(compile_pardot, "pardot");
compile_test!(compile_qualtrics, "qualtrics");
compile_test!(compile_instagram_business, "instagram-business");
compile_test!(compile_snapchat_ads, "snapchat-ads");
compile_test!(compile_microsoft_ads, "microsoft-ads");
compile_test!(compile_tiktok_ads, "tiktok-ads");
compile_test!(compile_reddit_ads, "reddit-ads");
compile_test!(compile_amazon_ads, "amazon-ads");
compile_test!(compile_apple_search_ads, "apple-search-ads");
compile_test!(compile_apple_store, "apple-store");
compile_test!(compile_google_play, "google-play");
compile_test!(compile_linkedin, "linkedin");
compile_test!(compile_linkedin_pages, "linkedin-pages");
compile_test!(compile_pinterest, "pinterest");
compile_test!(compile_twitter, "twitter");
compile_test!(compile_twitter_organic, "twitter-organic");
compile_test!(compile_youtube_analytics, "youtube-analytics");
compile_test!(compile_mixpanel, "mixpanel");
compile_test!(compile_facebook_pages, "facebook-pages");
compile_test!(compile_fivetran_log, "fivetran-log");
compile_test!(compile_amplitude, "amplitude");
compile_test!(compile_workday, "workday");
compile_test!(compile_zuora, "zuora");
compile_test!(compile_servicenow, "servicenow");
compile_test!(compile_twilio, "twilio");
compile_test!(compile_dynamics_365, "dynamics-365");
compile_test!(compile_social_media_reporting, "social-media-reporting");
compile_test!(compile_shopify_holistic, "shopify-holistic");
compile_test!(compile_app_reporting, "app-reporting");
compile_test!(compile_ga4_export, "ga4-export");
compile_test!(compile_sap, "sap");
compile_test!(compile_amazon_selling_partner, "amazon-selling-partner");

// Snowplow
compile_test!(compile_snowplow_unified, "snowplow-unified");
compile_test!(compile_snowplow_mobile, "snowplow-mobile");
compile_test!(compile_snowplow_ecommerce, "snowplow-ecommerce");

// Community
compile_test!(compile_dbt_artifacts, "dbt-artifacts");
compile_test!(compile_dbt_project_evaluator, "dbt-project-evaluator");
compile_test!(compile_snowplow_web, "snowplow-web");
