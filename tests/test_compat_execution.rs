//! Execution tests against generated compat projects.
//!
//! These tests use projects assembled by `scripts/generate_compat_projects.py`
//! from 66 open-source dbt repositories. Each project includes real models,
//! macros, and seed data from the upstream repo's integration tests.
//!
//! Tier 1 (compile): Load, parse, compile with airform (no execution).
//! Tier 2 (execute): Seed + execute with airform's DataFusion executor.
//!
//! Prerequisites:
//!   python3 scripts/generate_compat_projects.py
//!
//! Run:
//!   cargo test --test test_compat_execution -- --include-ignored

use std::path::PathBuf;

use airform_compiler::Compiler;
use airform_executor::{Executor, NodeStatus};
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
            errors: vec![],
        }
    }

    #[allow(dead_code)]
    fn compile_success_rate(&self) -> f64 {
        if self.models_found == 0 {
            return 0.0;
        }
        self.compiled_count as f64 / self.models_found as f64
    }
}

/// Load, parse, compile a project. Does not execute.
fn compile_project(name: &str) -> ProjectReport {
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
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

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

    // Compile
    let mut ctx = DbtContext::new(&load_state.project.name);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }

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

/// Load, parse, compile, seed, and execute a project.
async fn execute_project(name: &str) -> ProjectReport {
    let mut report = compile_project_with_manifest(name);
    if !report.compile_ok {
        return report;
    }

    let project_dir = compat_projects_dir().join(name);

    // Re-run full pipeline for execution
    let load_state = airform_loader::load_with_target(&project_dir, None).unwrap();
    let mut engine = JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

    let mut manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let graph = build_graph(&manifest).unwrap();

    let target_schema = load_state
        .target
        .as_ref()
        .and_then(|t| t.schema.clone())
        .unwrap_or_else(|| "main".to_string());

    let mut ctx = DbtContext::new(&load_state.project.name);
    ctx.execute = true;
    ctx.populate_vars(&load_state.project.vars);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }

    let compiler = Compiler::new(engine);
    let _ = compiler.compile(&mut manifest, &graph, &ctx);

    // Seed
    let executor = Executor::new(&target_schema);
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

    // Register empty tables for sources not backed by seeds
    if let Err(e) = executor.register_sources(&manifest).await {
        report.errors.push(format!("register_sources: {}", e));
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

/// Compile and return report (reused by execute_project).
fn compile_project_with_manifest(name: &str) -> ProjectReport {
    compile_project(name)
}

// ---------------------------------------------------------------------------
// Aggregate report test
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

#[tokio::test]
#[ignore = "tier2: requires generated projects (python3 scripts/generate_compat_projects.py)"]
async fn compat_execution_report() {
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
        "\n{:<30} {:>6} {:>8} {:>5} {:>5} {:>5} {:>5}",
        "PROJECT", "MODELS", "COMPILED", "SEEDS", "OK", "ERR", "SKIP"
    );
    println!("{}", "-".repeat(75));

    let mut total_success = 0;
    let mut total_error = 0;
    let mut total_skip = 0;

    for entry in &entries {
        let name = entry.file_name().to_string_lossy().to_string();
        let report = execute_project(&name).await;

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

        total_success += report.exec_success;
        total_error += report.exec_error;
        total_skip += report.exec_skip;
    }

    println!("{}", "-".repeat(75));
    println!(
        "TOTALS: {} succeeded, {} errored, {} skipped",
        total_success, total_error, total_skip
    );
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
