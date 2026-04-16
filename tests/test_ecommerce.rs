//! End-to-end integration tests against the ecommerce-analytics example project.

use std::path::PathBuf;

use airform_compiler::Compiler;
use airform_core::{ManifestNode, Materialization};
use airform_executor::{Executor, NodeStatus};
use airform_graph::build_graph;
use airform_jinja::{DbtContext, JinjaEngine};
use airform_loader;
use airform_parser;

fn ecommerce_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/ecommerce-analytics")
}

// ---------------------------------------------------------------------------
// Loading & Parsing
// ---------------------------------------------------------------------------

#[test]
fn test_load_ecommerce_project() {
    let load_state = airform_loader::load(&ecommerce_dir()).expect("failed to load ecommerce-analytics");
    assert_eq!(load_state.project.name, "ecommerce_analytics");
}

#[test]
fn test_ecommerce_model_count() {
    let load_state = airform_loader::load(&ecommerce_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    // 7 staging + 4 intermediate + 8 marts = 19 models
    let model_count = manifest.models().count();
    assert_eq!(model_count, 19, "expected 19 models, got {model_count}");
}

#[test]
fn test_ecommerce_seed_count() {
    let load_state = airform_loader::load(&ecommerce_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    let seed_count = manifest
        .nodes
        .values()
        .filter(|n| matches!(n, ManifestNode::Seed(_)))
        .count();
    assert_eq!(seed_count, 7, "expected 7 seeds, got {seed_count}");
}

#[test]
fn test_ecommerce_source_count() {
    let load_state = airform_loader::load(&ecommerce_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    // ecommerce source: 5 tables, web_analytics source: 2 tables = 7 total
    assert_eq!(
        manifest.sources.len(),
        7,
        "expected 7 sources, got {}",
        manifest.sources.len()
    );
}

#[test]
fn test_ecommerce_ephemeral_models_detected() {
    let load_state = airform_loader::load(&ecommerce_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    let ephemeral_count = manifest
        .models()
        .filter(|m| m.config.materialized == Materialization::Ephemeral)
        .count();
    assert_eq!(
        ephemeral_count, 4,
        "expected 4 ephemeral models (intermediate layer), got {ephemeral_count}"
    );
}

// ---------------------------------------------------------------------------
// Graph
// ---------------------------------------------------------------------------

#[test]
fn test_ecommerce_graph() {
    let load_state = airform_loader::load(&ecommerce_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let graph = build_graph(&manifest).unwrap();

    // 19 models + 7 seeds + 7 sources = 33 nodes
    assert!(
        graph.node_count() >= 33,
        "expected at least 33 nodes, got {}",
        graph.node_count()
    );

    let order = graph.topological_sort().unwrap();
    assert!(!order.is_empty());
}

// ---------------------------------------------------------------------------
// Compilation -- ephemeral CTE injection
// ---------------------------------------------------------------------------

fn compile_ecommerce() -> (airform_core::Manifest, airform_graph::DbtGraph, String) {
    let load_state = airform_loader::load(&ecommerce_dir()).unwrap();
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
        "compilation errors: {:?}",
        result.errors
    );

    (manifest, graph, target_schema)
}

#[test]
fn test_ecommerce_compilation_all_models() {
    let (manifest, _graph, _) = compile_ecommerce();

    for model in manifest.models() {
        assert!(
            model.compiled_sql.is_some(),
            "model {} should have compiled SQL",
            model.name
        );
    }
}

#[test]
fn test_ephemeral_cte_injection() {
    let (manifest, _graph, _) = compile_ecommerce();

    // The orders mart model depends on int_order_items_enriched, int_order_payments,
    // int_user_order_history -- all ephemeral.  Their compiled SQL should contain
    // __dbt__cte__ references.
    let orders_model = manifest
        .models()
        .find(|m| m.name == "orders")
        .expect("orders model not found");
    let sql = orders_model.compiled_sql.as_ref().unwrap();

    assert!(
        sql.contains("__dbt__cte__int_order_items_enriched"),
        "orders compiled SQL should contain __dbt__cte__int_order_items_enriched CTE.\nSQL:\n{sql}"
    );
    assert!(
        sql.contains("__dbt__cte__int_order_payments"),
        "orders compiled SQL should contain __dbt__cte__int_order_payments CTE.\nSQL:\n{sql}"
    );
    assert!(
        sql.contains("__dbt__cte__int_user_order_history"),
        "orders compiled SQL should contain __dbt__cte__int_user_order_history CTE.\nSQL:\n{sql}"
    );
}

#[test]
fn test_ephemeral_model_not_directly_referenced() {
    let (manifest, _graph, _) = compile_ecommerce();

    // Non-ephemeral models that depend on ephemeral models should NOT contain
    // the raw ephemeral model name as a FROM target without the __dbt__cte__ prefix.
    let orders_model = manifest
        .models()
        .find(|m| m.name == "orders")
        .expect("orders model not found");
    let sql = orders_model.compiled_sql.as_ref().unwrap();

    // The references should be via __dbt__cte__, not bare table names
    assert!(
        !sql.contains("{{ ref("),
        "compiled SQL should not contain raw Jinja"
    );
}

// ---------------------------------------------------------------------------
// Full execution pipeline
// ---------------------------------------------------------------------------

#[tokio::test]
async fn test_ecommerce_full_execution() {
    let (manifest, graph, target_schema) = compile_ecommerce();

    let executor = Executor::new(&target_schema);

    // Load seeds
    let seed_results = executor.load_seeds(&manifest).await.unwrap();
    for r in &seed_results {
        assert_eq!(
            r.status,
            NodeStatus::Success,
            "seed {} failed: {:?}",
            r.name,
            r.message
        );
    }

    // Execute all models
    let exec_result = executor.execute(&manifest, &graph, None).await.unwrap();

    // Ephemeral models should be skipped
    assert!(
        exec_result.skipped_count() >= 4,
        "expected at least 4 skipped (ephemeral) models, got {}",
        exec_result.skipped_count()
    );

    assert_eq!(
        exec_result.error_count(),
        0,
        "expected no execution errors, got: {:?}",
        exec_result
            .results
            .iter()
            .filter(|r| r.status == NodeStatus::Error)
            .map(|r| format!("{}: {:?}", r.name, r.message))
            .collect::<Vec<_>>()
    );

    // 19 models - 4 ephemeral = 15 executed successfully
    assert!(
        exec_result.success_count() >= 15,
        "expected at least 15 successful model executions, got {}",
        exec_result.success_count()
    );
}
