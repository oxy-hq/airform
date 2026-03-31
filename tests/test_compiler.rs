//! Tests for compilation: ephemeral CTE injection, WITH clause merging.

use std::path::PathBuf;

use airform_compiler::Compiler;
use airform_core::Materialization;
use airform_graph::build_graph;
use airform_jinja::{DbtContext, JinjaEngine};
use airform_loader;
use airform_parser;

fn ecommerce_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/ecommerce-analytics")
}

fn compile_ecommerce() -> airform_core::Manifest {
    let load_state = airform_loader::load(&ecommerce_dir()).unwrap();
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
    let result = compiler.compile(&mut manifest, &graph, &ctx).unwrap();
    assert_eq!(
        result.errors.len(),
        0,
        "compilation errors: {:?}",
        result.errors
    );

    manifest
}

// ---------------------------------------------------------------------------
// Ephemeral CTE injection
// ---------------------------------------------------------------------------

#[test]
fn test_ephemeral_cte_format() {
    let manifest = compile_ecommerce();

    // Find a model that depends on ephemeral models
    let orders_model = manifest
        .models()
        .find(|m| m.name == "orders")
        .expect("orders model not found");

    let sql = orders_model.compiled_sql.as_ref().unwrap();

    // Should contain a WITH clause with the ephemeral CTEs.
    // The SQL may start with leading comments before the WITH keyword.
    let upper = sql.to_uppercase();
    assert!(
        upper.contains("WITH "),
        "compiled SQL for model depending on ephemeral should contain WITH clause"
    );

    // Check that the CTE names follow the __dbt__cte__ convention
    assert!(
        sql.contains("__dbt__cte__"),
        "should contain __dbt__cte__ prefix for ephemeral models"
    );
}

#[test]
fn test_recursive_ephemeral_ctes() {
    let manifest = compile_ecommerce();

    // int_user_order_history depends on int_order_items_enriched (ephemeral -> ephemeral).
    // A model that depends on int_user_order_history should get both CTEs.
    let orders_model = manifest
        .models()
        .find(|m| m.name == "orders")
        .expect("orders model not found");

    let sql = orders_model.compiled_sql.as_ref().unwrap();

    // Should include the transitive ephemeral dependency
    assert!(
        sql.contains("__dbt__cte__int_order_items_enriched"),
        "should include transitive ephemeral dep int_order_items_enriched"
    );
    assert!(
        sql.contains("__dbt__cte__int_user_order_history"),
        "should include direct ephemeral dep int_user_order_history"
    );
}

#[test]
fn test_ephemeral_models_have_compiled_sql() {
    let manifest = compile_ecommerce();

    // Even ephemeral models should have their compiled SQL set
    for model in manifest.models() {
        if model.config.materialized == Materialization::Ephemeral {
            assert!(
                model.compiled_sql.is_some(),
                "ephemeral model {} should have compiled SQL",
                model.name
            );
        }
    }
}

// ---------------------------------------------------------------------------
// WITH clause merging
// ---------------------------------------------------------------------------

#[test]
fn test_with_clause_merging_in_existing_with() {
    let manifest = compile_ecommerce();

    // The orders mart model already has a WITH clause in its raw SQL.
    // After ephemeral CTE injection, there should be a single merged WITH block,
    // not nested WITH clauses.
    let orders_model = manifest
        .models()
        .find(|m| m.name == "orders")
        .expect("orders model not found");

    let sql = orders_model.compiled_sql.as_ref().unwrap();

    // Count occurrences of "with " at the start of lines (case-insensitive).
    // There should be exactly one WITH keyword introducing the CTE block.
    let with_count = sql
        .to_uppercase()
        .split('\n')
        .filter(|line| {
            let trimmed = line.trim();
            trimmed.starts_with("WITH ") || trimmed == "WITH"
        })
        .count();

    assert_eq!(
        with_count, 1,
        "should have exactly one WITH keyword after merging, got {with_count}.\nSQL:\n{sql}"
    );
}

// ---------------------------------------------------------------------------
// Non-ephemeral models
// ---------------------------------------------------------------------------

#[test]
fn test_staging_models_no_cte_injection() {
    let manifest = compile_ecommerce();

    // Staging models (view materialization) don't depend on ephemeral models,
    // so they should not have __dbt__cte__ prefixes.
    for model in manifest.models() {
        if model.name.starts_with("stg_") {
            if let Some(sql) = &model.compiled_sql {
                assert!(
                    !sql.contains("__dbt__cte__"),
                    "staging model {} should not have injected CTEs",
                    model.name
                );
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Compile result counts
// ---------------------------------------------------------------------------

#[test]
fn test_compile_result_counts() {
    let load_state = airform_loader::load(&ecommerce_dir()).unwrap();
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
    let result = compiler.compile(&mut manifest, &graph, &ctx).unwrap();

    // 19 models total
    assert_eq!(result.compiled_count, 19, "expected 19 compiled models");
    assert_eq!(result.errors.len(), 0, "expected 0 compilation errors");
}

// ---------------------------------------------------------------------------
// Compiled SQL correctness for jaffle-shop (no ephemeral models)
// ---------------------------------------------------------------------------

fn compile_jaffle_shop() -> airform_core::Manifest {
    let dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/jaffle-shop");
    let load_state = airform_loader::load(&dir).unwrap();
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
    let result = compiler.compile(&mut manifest, &graph, &ctx).unwrap();
    assert_eq!(result.errors.len(), 0);

    manifest
}

#[test]
fn test_jaffle_no_jinja_in_compiled_sql() {
    let manifest = compile_jaffle_shop();

    for model in manifest.models() {
        let sql = model.compiled_sql.as_ref().unwrap();
        assert!(
            !sql.contains("{{"),
            "model {} has unrendered Jinja: {}",
            model.name,
            &sql[..std::cmp::min(200, sql.len())]
        );
        assert!(
            !sql.contains("{%"),
            "model {} has unrendered Jinja block tags",
            model.name
        );
    }
}
