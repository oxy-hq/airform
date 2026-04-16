//! End-to-end integration tests against the jaffle-shop example project.

use std::path::PathBuf;

use airform_compiler::Compiler;
use airform_executor::{Executor, NodeStatus};
use airform_graph::build_graph;
use airform_jinja::{DbtContext, JinjaEngine};
use airform_loader;
use airform_parser;

fn jaffle_shop_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/jaffle-shop")
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

#[test]
fn test_load_project_succeeds() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).expect("failed to load jaffle-shop");
    assert_eq!(load_state.project.name, "jaffle_shop");
    assert!(load_state.profile.is_some(), "profile should be loaded");
    assert!(load_state.target.is_some(), "target should be loaded");
}

#[test]
fn test_load_discovers_model_files() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    // jaffle-shop has 5 model SQL files (3 staging + 2 marts)
    assert_eq!(
        load_state.model_files.len(),
        5,
        "expected 5 model files, got: {:?}",
        load_state.model_files.iter().map(|m| &m.name).collect::<Vec<_>>()
    );
}

#[test]
fn test_load_discovers_seed_files() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    // jaffle-shop has 3 seed CSVs
    assert_eq!(
        load_state.seed_files.len(),
        3,
        "expected 3 seed files, got: {:?}",
        load_state.seed_files.iter().map(|s| &s.name).collect::<Vec<_>>()
    );
}

#[test]
fn test_load_discovers_schema_files() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    // _sources.yml + staging/_schema.yml + marts/_schema.yml
    assert!(
        load_state.schema_files.len() >= 2,
        "expected at least 2 schema files, got {}",
        load_state.schema_files.len()
    );
}

// ---------------------------------------------------------------------------
// Parsing
// ---------------------------------------------------------------------------

#[test]
fn test_parse_produces_correct_model_count() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    let model_count = manifest.models().count();
    assert_eq!(model_count, 5, "expected 5 models in manifest");
}

#[test]
fn test_parse_produces_seeds() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    let seed_count = manifest
        .nodes
        .values()
        .filter(|n| matches!(n, airform_core::ManifestNode::Seed(_)))
        .count();
    assert_eq!(seed_count, 3, "expected 3 seeds in manifest");
}

#[test]
fn test_parse_produces_sources() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    // jaffle_shop source has 3 tables (raw_customers, raw_orders, raw_payments)
    assert_eq!(
        manifest.sources.len(),
        3,
        "expected 3 sources in manifest, got {}",
        manifest.sources.len()
    );
}

#[test]
fn test_parse_model_names() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    let mut model_names: Vec<String> = manifest.models().map(|m| m.name.clone()).collect();
    model_names.sort();

    let expected = vec![
        "customers",
        "orders",
        "stg_customers",
        "stg_orders",
        "stg_payments",
    ];
    assert_eq!(model_names, expected);
}

#[test]
fn test_parse_extracts_refs() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    // The customers mart model references stg_customers, stg_orders, stg_payments
    let customers_model = manifest
        .models()
        .find(|m| m.name == "customers")
        .expect("customers model not found");

    let ref_names: Vec<&str> = customers_model
        .depends_on
        .refs
        .iter()
        .map(|r| r.model_name.as_str())
        .collect();

    assert!(ref_names.contains(&"stg_customers"), "missing ref to stg_customers");
    assert!(ref_names.contains(&"stg_orders"), "missing ref to stg_orders");
    assert!(ref_names.contains(&"stg_payments"), "missing ref to stg_payments");
}

#[test]
fn test_parse_extracts_sources() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();

    // stg_customers references source('jaffle_shop', 'raw_customers')
    let stg_customers = manifest
        .models()
        .find(|m| m.name == "stg_customers")
        .expect("stg_customers model not found");

    assert!(
        !stg_customers.depends_on.sources.is_empty(),
        "stg_customers should have source dependencies"
    );

    let source_tables: Vec<&str> = stg_customers
        .depends_on
        .sources
        .iter()
        .map(|s| s.table_name.as_str())
        .collect();
    assert!(
        source_tables.contains(&"raw_customers"),
        "stg_customers should reference raw_customers source"
    );
}

// ---------------------------------------------------------------------------
// Graph
// ---------------------------------------------------------------------------

#[test]
fn test_graph_building() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let graph = build_graph(&manifest).unwrap();

    // 5 models + 3 seeds + 3 sources = 11 nodes
    assert!(
        graph.node_count() >= 11,
        "expected at least 11 nodes in graph, got {}",
        graph.node_count()
    );
    assert!(graph.edge_count() > 0, "graph should have edges");
}

#[test]
fn test_topological_sort() {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let graph = build_graph(&manifest).unwrap();

    let order = graph.topological_sort().unwrap();
    assert!(!order.is_empty(), "topological sort should produce a non-empty order");

    // Sources and seeds must come before models that depend on them.
    // Specifically, stg_customers must come before customers.
    let stg_cust_pos = order.iter().position(|id| id.contains("stg_customers"));
    let cust_pos = order.iter().position(|id| id.contains("model.jaffle_shop.customers"));
    if let (Some(stg), Some(cust)) = (stg_cust_pos, cust_pos) {
        assert!(
            stg < cust,
            "stg_customers should come before customers in topological order"
        );
    }
}

// ---------------------------------------------------------------------------
// Compilation
// ---------------------------------------------------------------------------

fn compile_jaffle_shop() -> (airform_core::Manifest, airform_graph::DbtGraph, String) {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
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
    assert_eq!(result.errors.len(), 0, "compilation errors: {:?}", result.errors);
    assert_eq!(result.compiled_count, 5, "expected 5 compiled models");

    (manifest, graph, target_schema)
}

#[test]
fn test_compilation_produces_sql_for_all_models() {
    let (manifest, _graph, _) = compile_jaffle_shop();

    for model in manifest.models() {
        assert!(
            model.compiled_sql.is_some(),
            "model {} should have compiled SQL",
            model.name
        );
    }
}

#[test]
fn test_compiled_sql_resolves_refs() {
    let (manifest, _graph, _) = compile_jaffle_shop();

    // The customers model references stg_customers; after compilation, the
    // compiled SQL should contain the resolved table name (stg_customers),
    // not the raw {{ ref('stg_customers') }} call.
    let customers = manifest
        .models()
        .find(|m| m.name == "customers")
        .unwrap();
    let sql = customers.compiled_sql.as_ref().unwrap();

    assert!(
        !sql.contains("{{ ref("),
        "compiled SQL should not contain raw Jinja ref() calls"
    );
    assert!(
        sql.contains("stg_customers"),
        "compiled SQL should reference the resolved stg_customers table"
    );
}

#[test]
fn test_compiled_sql_resolves_sources() {
    let (manifest, _graph, _) = compile_jaffle_shop();

    // stg_customers references source('jaffle_shop', 'raw_customers')
    // After compilation the raw_customers table name should appear.
    let stg_cust = manifest
        .models()
        .find(|m| m.name == "stg_customers")
        .unwrap();
    let sql = stg_cust.compiled_sql.as_ref().unwrap();

    assert!(
        !sql.contains("{{ source("),
        "compiled SQL should not contain raw Jinja source() calls"
    );
    assert!(
        sql.contains("raw_customers"),
        "compiled SQL should contain the resolved source table name 'raw_customers'"
    );
}

// ---------------------------------------------------------------------------
// Full execution pipeline
// ---------------------------------------------------------------------------

#[tokio::test]
async fn test_full_execution_pipeline() {
    let (manifest, graph, target_schema) = compile_jaffle_shop();

    let executor = Executor::new(&target_schema);

    // Load seeds first
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
    assert!(
        exec_result.success_count() >= 5,
        "expected at least 5 successful model executions, got {}",
        exec_result.success_count()
    );
}

#[tokio::test]
async fn test_can_query_executed_models() {
    let (manifest, graph, target_schema) = compile_jaffle_shop();

    let executor = Executor::new(&target_schema);
    executor.load_seeds(&manifest).await.unwrap();
    executor.execute(&manifest, &graph, None).await.unwrap();

    // Query the customers model using schema-qualified name
    let result = executor
        .execute_query("SELECT count(*) as cnt FROM main.customers")
        .await
        .unwrap();
    assert!(result.row_count > 0, "customers table should have rows");
}
