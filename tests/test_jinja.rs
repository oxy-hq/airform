//! Unit-level tests for the Jinja rendering engine.

use airform_jinja::{DbtContext, JinjaEngine};

fn default_ctx() -> DbtContext {
    DbtContext::new("test_project")
}

// ---------------------------------------------------------------------------
// ref()
// ---------------------------------------------------------------------------

#[test]
fn test_ref_renders_in_parse_mode() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx(); // execute=false by default

    let sql = "SELECT * FROM {{ ref('stg_customers') }}";
    let rendered = engine.render(sql, &ctx).unwrap();

    // In parse mode, ref() returns __dbt__cte__<model_name>
    assert!(
        rendered.contains("__dbt__cte__stg_customers"),
        "expected __dbt__cte__stg_customers, got: {rendered}"
    );
}

#[test]
fn test_ref_renders_in_execute_mode() {
    let engine = JinjaEngine::new();
    let mut ctx = default_ctx();
    ctx.execute = true;
    ctx.ref_resolutions
        .insert("stg_customers".to_string(), "main.stg_customers".to_string());

    let sql = "SELECT * FROM {{ ref('stg_customers') }}";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("main.stg_customers"),
        "expected resolved ref 'main.stg_customers', got: {rendered}"
    );
}

#[test]
fn test_ref_captures_dependency() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT * FROM {{ ref('stg_orders') }}";
    engine.render(sql, &ctx).unwrap();

    let refs = ctx.take_refs();
    assert_eq!(refs.len(), 1);
    assert_eq!(refs[0].model_name, "stg_orders");
    assert!(refs[0].package.is_none());
}

#[test]
fn test_ref_with_package() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT * FROM {{ ref('other_project', 'shared_model') }}";
    engine.render(sql, &ctx).unwrap();

    let refs = ctx.take_refs();
    assert_eq!(refs.len(), 1);
    assert_eq!(refs[0].model_name, "shared_model");
    assert_eq!(refs[0].package.as_deref(), Some("other_project"));
}

#[test]
fn test_multiple_refs() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT a.*, b.* FROM {{ ref('model_a') }} a JOIN {{ ref('model_b') }} b ON a.id = b.id";
    engine.render(sql, &ctx).unwrap();

    let refs = ctx.take_refs();
    assert_eq!(refs.len(), 2);
    let names: Vec<&str> = refs.iter().map(|r| r.model_name.as_str()).collect();
    assert!(names.contains(&"model_a"));
    assert!(names.contains(&"model_b"));
}

// ---------------------------------------------------------------------------
// source()
// ---------------------------------------------------------------------------

#[test]
fn test_source_renders_in_parse_mode() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT * FROM {{ source('jaffle_shop', 'raw_customers') }}";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("jaffle_shop.raw_customers"),
        "expected source rendered as jaffle_shop.raw_customers, got: {rendered}"
    );
}

#[test]
fn test_source_renders_in_execute_mode() {
    let engine = JinjaEngine::new();
    let mut ctx = default_ctx();
    ctx.execute = true;
    ctx.source_resolutions.insert(
        ("jaffle_shop".to_string(), "raw_customers".to_string()),
        "raw_customers".to_string(),
    );

    let sql = "SELECT * FROM {{ source('jaffle_shop', 'raw_customers') }}";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("raw_customers"),
        "expected resolved source table name, got: {rendered}"
    );
}

#[test]
fn test_source_captures_dependency() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT * FROM {{ source('my_source', 'my_table') }}";
    engine.render(sql, &ctx).unwrap();

    let sources = ctx.take_sources();
    assert_eq!(sources.len(), 1);
    assert_eq!(sources[0].source_name, "my_source");
    assert_eq!(sources[0].table_name, "my_table");
}

// ---------------------------------------------------------------------------
// config()
// ---------------------------------------------------------------------------

#[test]
fn test_config_extraction() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "{{ config(materialized='table', schema='analytics') }}\nSELECT 1";
    engine.render(sql, &ctx).unwrap();

    let config = ctx.take_config();
    assert_eq!(config.get("materialized").map(|s| s.as_str()), Some("table"));
    assert_eq!(config.get("schema").map(|s| s.as_str()), Some("analytics"));
}

#[test]
fn test_config_returns_empty_string() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    // config() should produce no visible output in the rendered SQL
    let sql = "{{ config(materialized='view') }}SELECT 1 as id";
    let rendered = engine.render(sql, &ctx).unwrap();

    // The rendered output should just be the SELECT statement
    assert!(
        rendered.contains("SELECT 1 as id"),
        "config() output should not interfere with SQL"
    );
}

// ---------------------------------------------------------------------------
// var()
// ---------------------------------------------------------------------------

#[test]
fn test_var_with_value() {
    let engine = JinjaEngine::new();
    let mut ctx = default_ctx();
    ctx.vars.insert("my_var".to_string(), "hello".to_string());

    let sql = "SELECT '{{ var('my_var') }}' as val";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("hello"),
        "expected var to resolve to 'hello', got: {rendered}"
    );
}

#[test]
fn test_var_with_default() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT '{{ var('undefined_var', 'default_value') }}' as val";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("default_value"),
        "expected default value, got: {rendered}"
    );
}

// ---------------------------------------------------------------------------
// env_var()
// ---------------------------------------------------------------------------

#[test]
fn test_env_var_with_existing_var() {
    // Use a variable that is always set
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    // Set a test environment variable
    // SAFETY: This test is single-threaded and the variable is removed before returning.
    unsafe { std::env::set_var("AIRFORM_TEST_VAR", "test_value_123"); }

    let sql = "SELECT '{{ env_var('AIRFORM_TEST_VAR') }}' as val";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("test_value_123"),
        "expected env var value, got: {rendered}"
    );

    unsafe { std::env::remove_var("AIRFORM_TEST_VAR"); }
}

#[test]
fn test_env_var_with_default() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT '{{ env_var('NONEXISTENT_AIRFORM_VAR', 'fallback') }}' as val";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("fallback"),
        "expected fallback value, got: {rendered}"
    );
}

#[test]
fn test_env_var_missing_no_default_errors() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT '{{ env_var('DEFINITELY_NOT_SET_AIRFORM_XYZ') }}' as val";
    let result = engine.render(sql, &ctx);

    assert!(result.is_err(), "env_var without default should error when var is not set");
}

// ---------------------------------------------------------------------------
// is_incremental()
// ---------------------------------------------------------------------------

#[test]
fn test_is_incremental_returns_false() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "{% if is_incremental() %}WHERE updated_at > '2024-01-01'{% endif %}SELECT 1 as id";
    let rendered = engine.render(sql, &ctx).unwrap();

    // is_incremental() returns false, so the WHERE clause should not appear
    assert!(
        !rendered.contains("WHERE updated_at"),
        "is_incremental() should return false, got: {rendered}"
    );
}

// ---------------------------------------------------------------------------
// Custom macros
// ---------------------------------------------------------------------------

#[test]
fn test_custom_macro_loading_and_rendering() {
    let mut engine = JinjaEngine::new();

    // Register a custom macro
    engine.load_macros(&[(
        "cents_to_dollars".to_string(),
        vec!["column_name".to_string()],
        "({{ column_name }} / 100)::numeric(16, 2)".to_string(),
    )]);

    let ctx = default_ctx();
    let sql = "SELECT {{ cents_to_dollars('amount') }} as amount_dollars";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("(amount / 100)::numeric(16, 2)"),
        "expected macro expansion, got: {rendered}"
    );
}

#[test]
fn test_custom_macro_with_multiple_args() {
    let mut engine = JinjaEngine::new();

    engine.load_macros(&[(
        "safe_divide".to_string(),
        vec!["numerator".to_string(), "denominator".to_string()],
        "CASE WHEN {{ denominator }} = 0 THEN NULL ELSE {{ numerator }} / {{ denominator }} END".to_string(),
    )]);

    let ctx = default_ctx();
    let sql = "SELECT {{ safe_divide('revenue', 'users') }} as arpu";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(rendered.contains("CASE WHEN"), "expected CASE WHEN in output, got: {rendered}");
    assert!(rendered.contains("revenue"), "expected 'revenue' in output, got: {rendered}");
    assert!(rendered.contains("users"), "expected 'users' in output, got: {rendered}");
}

// ---------------------------------------------------------------------------
// target context
// ---------------------------------------------------------------------------

#[test]
fn test_target_context() {
    let engine = JinjaEngine::new();
    let mut ctx = default_ctx();
    ctx.target_name = "prod".to_string();
    ctx.target_schema = "analytics".to_string();
    ctx.target_type = "postgres".to_string();

    let sql = "SELECT '{{ target.name }}' as env, '{{ target.schema }}' as schema, '{{ target.type }}' as db_type";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(rendered.contains("prod"), "expected target.name=prod, got: {rendered}");
    assert!(rendered.contains("analytics"), "expected target.schema=analytics, got: {rendered}");
    assert!(rendered.contains("postgres"), "expected target.type=postgres, got: {rendered}");
}

// ---------------------------------------------------------------------------
// Jinja control flow
// ---------------------------------------------------------------------------

#[test]
fn test_jinja_if_else() {
    let engine = JinjaEngine::new();
    let mut ctx = default_ctx();
    ctx.target_name = "prod".to_string();

    let sql = "SELECT {% if target.name == 'prod' %}production_table{% else %}dev_table{% endif %} as t";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("production_table"),
        "expected production_table in prod target, got: {rendered}"
    );
}

#[test]
fn test_jinja_for_loop() {
    let engine = JinjaEngine::new();
    let ctx = default_ctx();

    let sql = "SELECT {% for col in ['a', 'b', 'c'] %}{{ col }}{% if not loop.last %}, {% endif %}{% endfor %}";
    let rendered = engine.render(sql, &ctx).unwrap();

    assert!(
        rendered.contains("a, b, c"),
        "expected 'a, b, c' in rendered output, got: {rendered}"
    );
}
