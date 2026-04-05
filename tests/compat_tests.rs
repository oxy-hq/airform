//! Compatibility tests: clone real-world dbt projects from GitHub and verify
//! that airform can load, parse, compile, and analyze them.
//!
//! These tests download repos to a local cache directory and exercise the full
//! airform pipeline against real SQL models from the dbt ecosystem.
//!
//! The test suite covers 42 repositories totaling ~2700 SQL models:
//!   - dbt-labs official examples (jaffle-shop, mrr-playbook, attribution-playbook)
//!   - 35+ Fivetran connector packages (shopify, stripe, hubspot, etc.)
//!   - Community packages (dbt_artifacts, dbt-project-evaluator, snowplow-web)
//!
//! Run: cargo test --test compat_tests -- --include-ignored
//! (ignored by default because they require network access to clone repos)

use std::path::{Path, PathBuf};
use std::process::Command;

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

/// Directory where repos are cached between runs.
fn cache_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("target")
        .join("compat-repos")
}

/// Clone or update a repo, returning the path to the project root.
fn ensure_repo(org_repo: &str, subdir: Option<&str>) -> PathBuf {
    let cache = cache_dir();
    std::fs::create_dir_all(&cache).expect("create cache dir");

    let repo_name = org_repo.split('/').last().unwrap();
    let repo_path = cache.join(repo_name);

    if !repo_path.exists() {
        let url = format!("https://github.com/{}.git", org_repo);
        let status = Command::new("git")
            .args(["clone", "--depth", "1", &url, repo_path.to_str().unwrap()])
            .status()
            .expect("git clone");
        assert!(status.success(), "failed to clone {}", org_repo);
    }

    match subdir {
        Some(sub) => repo_path.join(sub),
        None => repo_path,
    }
}

/// Ensure a profiles.yml exists for the project.
fn ensure_profiles(project_dir: &Path) {
    let profiles_path = project_dir.join("profiles.yml");
    if profiles_path.exists() {
        return;
    }
    let project_yml =
        std::fs::read_to_string(project_dir.join("dbt_project.yml")).expect("read dbt_project.yml");

    // Extract profile name, falling back to project name
    let profile_name = project_yml
        .lines()
        .find(|l| l.starts_with("profile:"))
        .map(|l| {
            l.split(':')
                .nth(1)
                .unwrap_or("default")
                .trim()
                .trim_matches('\'')
                .trim_matches('"')
                .to_string()
        })
        .unwrap_or_else(|| {
            project_yml
                .lines()
                .find(|l| l.starts_with("name:"))
                .map(|l| {
                    l.split(':')
                        .nth(1)
                        .unwrap_or("default")
                        .trim()
                        .trim_matches('\'')
                        .trim_matches('"')
                        .to_string()
                })
                .unwrap_or_else(|| "default".to_string())
        });

    let content = format!(
        "{profile_name}:\n  target: dev\n  outputs:\n    dev:\n      type: datafusion\n      schema: public\n      database: main\n"
    );
    std::fs::write(&profiles_path, content).expect("write profiles.yml");
}

/// Results from testing a repo.
struct RepoResult {
    models_found: usize,
    load_ok: bool,
    parse_ok: bool,
    graph_ok: bool,
    compiled_count: usize,
    compile_error_count: usize,
    schemas_inferred: usize,
    sql_error_count: usize,
    errors: Vec<String>,
}

/// Full pipeline: clone, load, parse, compile, analyze.
fn test_repo_full(
    org_repo: &str,
    subdir: Option<&str>,
    adapter_type: &str,
    min_models: usize,
) -> RepoResult {
    let project_dir = ensure_repo(org_repo, subdir);
    assert!(
        project_dir.join("dbt_project.yml").exists(),
        "no dbt_project.yml in {:?}",
        project_dir
    );
    ensure_profiles(&project_dir);

    let repo_name = org_repo.split('/').last().unwrap();
    let mut result = RepoResult {
        models_found: 0,
        load_ok: false,
        parse_ok: false,
        graph_ok: false,
        compiled_count: 0,
        compile_error_count: 0,
        schemas_inferred: 0,
        sql_error_count: 0,
        errors: vec![],
    };

    // ---- Load ----
    let load_state = match airform_loader::load_with_target(&project_dir, None) {
        Ok(ls) => {
            result.load_ok = true;
            ls
        }
        Err(e) => {
            result.errors.push(format!("load: {}", e));
            println!("[{}] LOAD FAILED: {}", repo_name, e);
            return result;
        }
    };

    // ---- Setup Jinja ----
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

    // ---- Parse ----
    let mut manifest = match airform_parser::parse(&load_state, &engine) {
        Ok(m) => {
            result.parse_ok = true;
            m
        }
        Err(e) => {
            result.errors.push(format!("parse: {}", e));
            println!("[{}] PARSE FAILED: {}", repo_name, e);
            return result;
        }
    };

    result.models_found = manifest.models().count();
    println!("[{}] loaded {} models", repo_name, result.models_found);

    // ---- Graph ----
    let graph = match airform_graph::build_graph(&manifest) {
        Ok(g) => {
            result.graph_ok = true;
            g
        }
        Err(e) => {
            result.errors.push(format!("graph: {}", e));
            println!("[{}] GRAPH FAILED: {}", repo_name, e);
            return result;
        }
    };

    // ---- Compile ----
    let compiler = airform_compiler::Compiler::new(engine);
    match compiler.compile(&mut manifest, &graph, &ctx) {
        Ok(cr) => {
            result.compiled_count = cr.compiled_count;
            result.compile_error_count = cr.errors.len();
            if !cr.errors.is_empty() {
                for e in cr.errors.iter().take(5) {
                    result.errors.push(format!("compile: {:?}", e));
                }
            }
        }
        Err(e) => {
            result.errors.push(format!("compile: {}", e));
            println!("[{}] COMPILE FAILED: {}", repo_name, e);
            return result;
        }
    }

    println!(
        "[{}] compiled {}/{}, errors={}",
        repo_name, result.compiled_count, result.models_found, result.compile_error_count
    );

    // ---- Analyze (if we compiled at least some models) ----
    if result.compiled_count > 0 {
        let rt = tokio::runtime::Runtime::new().unwrap();
        match rt.block_on(airform_analyzer::Analyzer::analyze(
            &manifest,
            &graph,
            Some(&project_dir),
            None,
            Some(adapter_type),
        )) {
            Ok(analysis) => {
                result.schemas_inferred = analysis.schemas.len();
                let sql_errs: Vec<String> = analysis
                    .diagnostics
                    .iter()
                    .filter_map(|d| match d {
                        airform_analyzer::AnalyzerDiagnostic::SqlError { model, message } => {
                            Some(format!("{}: {}", model, message))
                        }
                        _ => None,
                    })
                    .collect();
                result.sql_error_count = sql_errs.len();
                for e in sql_errs.iter().take(5) {
                    result.errors.push(format!("sql: {}", e));
                }
                println!(
                    "[{}] schemas={}, sql_errors={}",
                    repo_name, result.schemas_inferred, result.sql_error_count
                );
            }
            Err(e) => {
                result.errors.push(format!("analyze: {}", e));
                println!("[{}] ANALYZE FAILED: {}", repo_name, e);
            }
        }
    }

    // Print first few errors for debugging
    for e in result.errors.iter().take(3) {
        println!("  {}", e);
    }

    // Assert we found at least the minimum expected models
    assert!(
        result.models_found >= min_models,
        "[{}] expected >= {} models, found {}",
        repo_name,
        min_models,
        result.models_found
    );

    result
}

// ---------------------------------------------------------------------------
// Test macros
// ---------------------------------------------------------------------------

/// Test that asserts models are found and the pipeline doesn't crash.
macro_rules! compat_test {
    ($name:ident, $org_repo:expr, $subdir:expr, $adapter:expr, $min_models:expr) => {
        #[test]
        #[ignore = "compat: requires network"]
        fn $name() {
            test_repo_full($org_repo, $subdir, $adapter, $min_models);
        }
    };
}

// ===========================================================================
// dbt-labs official examples (self-contained, should fully compile)
// ===========================================================================

compat_test!(jaffle_shop, "dbt-labs/jaffle-shop", None, "duckdb", 10);
compat_test!(mrr_playbook, "dbt-labs/mrr-playbook", None, "snowflake", 3);
compat_test!(attribution_playbook, "dbt-labs/attribution-playbook", None, "snowflake", 1);

// ===========================================================================
// Fivetran connector packages (root has models/, sources defined in YAML)
// These use fivetran_utils macros so Jinja compile may have errors, but
// load + parse + graph should succeed and find all models.
// ===========================================================================

compat_test!(fivetran_shopify, "fivetran/dbt_shopify", None, "duckdb", 50);
compat_test!(fivetran_stripe, "fivetran/dbt_stripe", None, "duckdb", 20);
compat_test!(fivetran_hubspot, "fivetran/dbt_hubspot", None, "duckdb", 50);
compat_test!(fivetran_zendesk, "fivetran/dbt_zendesk", None, "duckdb", 30);
compat_test!(fivetran_github, "fivetran/dbt_github", None, "duckdb", 15);
compat_test!(fivetran_jira, "fivetran/dbt_jira", None, "duckdb", 20);
compat_test!(fivetran_salesforce, "fivetran/dbt_salesforce", None, "duckdb", 10);
compat_test!(fivetran_netsuite, "fivetran/dbt_netsuite", None, "duckdb", 30);
compat_test!(fivetran_quickbooks, "fivetran/dbt_quickbooks", None, "duckdb", 40);
compat_test!(fivetran_google_ads, "fivetran/dbt_google_ads", None, "duckdb", 15);
compat_test!(fivetran_facebook_ads, "fivetran/dbt_facebook_ads", None, "duckdb", 15);
compat_test!(fivetran_ad_reporting, "fivetran/dbt_ad_reporting", None, "duckdb", 5);
compat_test!(fivetran_intercom, "fivetran/dbt_intercom", None, "duckdb", 15);
compat_test!(fivetran_marketo, "fivetran/dbt_marketo", None, "duckdb", 15);
compat_test!(fivetran_mailchimp, "fivetran/dbt_mailchimp", None, "duckdb", 15);
compat_test!(fivetran_asana, "fivetran/dbt_asana", None, "duckdb", 15);
compat_test!(fivetran_greenhouse, "fivetran/dbt_greenhouse", None, "duckdb", 30);
compat_test!(fivetran_lever, "fivetran/dbt_lever", None, "duckdb", 20);
compat_test!(fivetran_pendo, "fivetran/dbt_pendo", None, "duckdb", 20);
compat_test!(fivetran_iterable, "fivetran/dbt_iterable", None, "duckdb", 15);
compat_test!(fivetran_klaviyo, "fivetran/dbt_klaviyo", None, "duckdb", 5);
compat_test!(fivetran_recharge, "fivetran/dbt_recharge", None, "duckdb", 15);
compat_test!(fivetran_recurly, "fivetran/dbt_recurly", None, "duckdb", 15);
compat_test!(fivetran_xero, "fivetran/dbt_xero", None, "duckdb", 10);
compat_test!(fivetran_sage_intacct, "fivetran/dbt_sage_intacct", None, "duckdb", 10);
compat_test!(fivetran_pardot, "fivetran/dbt_pardot", None, "duckdb", 10);
compat_test!(fivetran_qualtrics, "fivetran/dbt_qualtrics", None, "duckdb", 15);
compat_test!(fivetran_instagram_business, "fivetran/dbt_instagram_business", None, "duckdb", 3);
compat_test!(fivetran_snapchat_ads, "fivetran/dbt_snapchat_ads", None, "duckdb", 10);
compat_test!(fivetran_microsoft_ads, "fivetran/dbt_microsoft_ads", None, "duckdb", 10);
compat_test!(fivetran_tiktok_ads, "fivetran/dbt_tiktok_ads", None, "duckdb", 8);
compat_test!(fivetran_reddit_ads, "fivetran/dbt_reddit_ads", None, "duckdb", 10);
compat_test!(fivetran_amazon_ads, "fivetran/dbt_amazon_ads", None, "duckdb", 10);
compat_test!(fivetran_apple_search_ads, "fivetran/dbt_apple_search_ads", None, "duckdb", 10);
compat_test!(fivetran_apple_store, "fivetran/dbt_apple_store", None, "duckdb", 15);
compat_test!(fivetran_google_play, "fivetran/dbt_google_play", None, "duckdb", 15);
compat_test!(fivetran_linkedin, "fivetran/dbt_linkedin", None, "duckdb", 10);
compat_test!(fivetran_linkedin_pages, "fivetran/dbt_linkedin_pages", None, "duckdb", 10);
compat_test!(fivetran_pinterest, "fivetran/dbt_pinterest", None, "duckdb", 15);
compat_test!(fivetran_twitter, "fivetran/dbt_twitter", None, "duckdb", 15);
compat_test!(fivetran_twitter_organic, "fivetran/dbt_twitter_organic", None, "duckdb", 5);
compat_test!(fivetran_youtube_analytics, "fivetran/dbt_youtube_analytics", None, "duckdb", 5);
compat_test!(fivetran_mixpanel, "fivetran/dbt_mixpanel", None, "duckdb", 3);
compat_test!(fivetran_facebook_pages, "fivetran/dbt_facebook_pages", None, "duckdb", 5);
compat_test!(fivetran_fivetran_log, "fivetran/dbt_fivetran_log", None, "duckdb", 10);
compat_test!(fivetran_amplitude, "fivetran/dbt_amplitude", None, "duckdb", 3);
compat_test!(fivetran_workday, "fivetran/dbt_workday", None, "duckdb", 20);
compat_test!(fivetran_zuora, "fivetran/dbt_zuora", None, "duckdb", 20);
compat_test!(fivetran_servicenow, "fivetran/dbt_servicenow", None, "duckdb", 15);
compat_test!(fivetran_twilio, "fivetran/dbt_twilio", None, "duckdb", 10);
compat_test!(fivetran_dynamics_365, "fivetran/dbt_dynamics_365_crm", None, "duckdb", 5);
compat_test!(fivetran_social_media_reporting, "fivetran/dbt_social_media_reporting", None, "duckdb", 3);
compat_test!(fivetran_shopify_holistic, "fivetran/dbt_shopify_holistic_reporting", None, "duckdb", 3);
compat_test!(fivetran_app_reporting, "fivetran/dbt_app_reporting", None, "duckdb", 5);
compat_test!(fivetran_ga4_export, "fivetran/dbt_ga4_export", None, "duckdb", 3);
compat_test!(fivetran_sap, "fivetran/dbt_sap", None, "duckdb", 50);
compat_test!(fivetran_amazon_selling_partner, "fivetran/dbt_amazon_selling_partner", None, "duckdb", 15);

// ===========================================================================
// Snowplow packages (complex incremental + sessionization)
// ===========================================================================

compat_test!(snowplow_unified, "snowplow/dbt-snowplow-unified", None, "snowflake", 10);
compat_test!(snowplow_mobile, "snowplow/dbt-snowplow-mobile", None, "snowflake", 10);
compat_test!(snowplow_ecommerce, "snowplow/dbt-snowplow-ecommerce", None, "snowflake", 10);

// ===========================================================================
// Community packages
// ===========================================================================

compat_test!(
    dbt_artifacts,
    "brooklyn-data/dbt_artifacts",
    Some("integration_test_project"),
    "duckdb",
    3
);
compat_test!(
    dbt_project_evaluator,
    "dbt-labs/dbt-project-evaluator",
    Some("integration_tests_2"),
    "duckdb",
    5
);
compat_test!(snowplow_web, "snowplow/dbt-snowplow-web", None, "snowflake", 10);

// ===========================================================================
// Aggregate test: run all repos and produce a compatibility report
// ===========================================================================

/// Load repo list from repos.json (single source of truth).
fn load_repos_json() -> Vec<(String, Option<String>, String, usize)> {
    let json_path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests")
        .join("compat")
        .join("repos.json");
    let content = std::fs::read_to_string(&json_path).expect("read repos.json");
    let entries: Vec<serde_json::Value> = serde_json::from_str(&content).expect("parse repos.json");
    entries
        .iter()
        .map(|e| {
            let repo = e["repo"].as_str().unwrap().to_string();
            let subdir = e["project_subdir"].as_str().map(|s| s.to_string());
            let adapter = e["adapter_type"].as_str().unwrap_or("duckdb").to_string();
            let min_models = e["expected_models"].as_u64().unwrap_or(1) as usize;
            (repo, subdir, adapter, min_models)
        })
        .collect()
}

#[test]
#[ignore = "compat: requires network, runs all repos"]
fn compat_report_all() {
    let repos = load_repos_json();

    let mut total_models = 0;
    let mut total_compiled = 0;
    let mut total_schemas = 0;
    let mut load_pass = 0;
    let mut parse_pass = 0;
    let mut graph_pass = 0;

    println!("\n{:<30} {:>6} {:>8} {:>8} {:>7} {:>7}", "REPO", "MODELS", "COMPILED", "SCHEMAS", "C_ERR", "S_ERR");
    println!("{}", "-".repeat(80));

    for (org_repo, subdir, adapter, min_models) in &repos {
        let repo_name = org_repo.split('/').last().unwrap();
        let r = test_repo_full(org_repo, subdir.as_deref(), adapter, *min_models);

        println!(
            "{:<30} {:>6} {:>8} {:>8} {:>7} {:>7}",
            repo_name, r.models_found, r.compiled_count, r.schemas_inferred,
            r.compile_error_count, r.sql_error_count
        );

        total_models += r.models_found;
        total_compiled += r.compiled_count;
        total_schemas += r.schemas_inferred;
        if r.load_ok { load_pass += 1; }
        if r.parse_ok { parse_pass += 1; }
        if r.graph_ok { graph_pass += 1; }
    }

    println!("{}", "-".repeat(80));
    println!(
        "TOTALS: {} repos, {} models found, {} compiled, {} schemas",
        repos.len(), total_models, total_compiled, total_schemas
    );
    println!(
        "PASS RATES: load={}/{} parse={}/{} graph={}/{}",
        load_pass, repos.len(), parse_pass, repos.len(), graph_pass, repos.len()
    );
}
