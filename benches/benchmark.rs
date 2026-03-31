use criterion::{criterion_group, criterion_main, Criterion};
use std::path::PathBuf;

fn project_path(name: &str) -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("examples")
        .join(name)
}

fn setup_engine(load_state: &airform_loader::LoadState) -> airform_jinja::JinjaEngine {
    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);
    engine
}

fn setup_context(load_state: &airform_loader::LoadState) -> airform_jinja::DbtContext {
    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }
    ctx
}

// ---------------------------------------------------------------------------
// Loading benchmarks
// ---------------------------------------------------------------------------

fn bench_load(c: &mut Criterion) {
    let mut group = c.benchmark_group("load");

    for name in &["jaffle-shop", "ecommerce-analytics"] {
        let path = project_path(name);
        if !path.exists() {
            eprintln!("Skipping {name}: example project not found at {}", path.display());
            continue;
        }
        group.bench_function(*name, |b| {
            b.iter(|| {
                airform_loader::load(&path).expect("load failed");
            });
        });
    }

    group.finish();
}

// ---------------------------------------------------------------------------
// Parsing benchmarks
// ---------------------------------------------------------------------------

fn bench_parse(c: &mut Criterion) {
    let mut group = c.benchmark_group("parse");

    for name in &["jaffle-shop", "ecommerce-analytics"] {
        let path = project_path(name);
        if !path.exists() {
            continue;
        }
        let load_state = airform_loader::load(&path).expect("load failed");
        let engine = setup_engine(&load_state);

        group.bench_function(*name, |b| {
            b.iter(|| {
                airform_parser::parse(&load_state, &engine).expect("parse failed");
            });
        });
    }

    group.finish();
}

// ---------------------------------------------------------------------------
// Graph building benchmarks
// ---------------------------------------------------------------------------

fn bench_graph(c: &mut Criterion) {
    let mut group = c.benchmark_group("graph");

    for name in &["jaffle-shop", "ecommerce-analytics"] {
        let path = project_path(name);
        if !path.exists() {
            continue;
        }
        let load_state = airform_loader::load(&path).expect("load failed");
        let engine = setup_engine(&load_state);
        let manifest = airform_parser::parse(&load_state, &engine).expect("parse failed");

        group.bench_function(*name, |b| {
            b.iter(|| {
                airform_graph::build_graph(&manifest).expect("graph build failed");
            });
        });
    }

    group.finish();
}

// ---------------------------------------------------------------------------
// Compilation benchmarks
// ---------------------------------------------------------------------------

fn bench_compile(c: &mut Criterion) {
    let mut group = c.benchmark_group("compile");

    for name in &["jaffle-shop", "ecommerce-analytics"] {
        let path = project_path(name);
        if !path.exists() {
            continue;
        }
        let load_state = airform_loader::load(&path).expect("load failed");
        let engine = setup_engine(&load_state);
        let manifest = airform_parser::parse(&load_state, &engine).expect("parse failed");
        let graph = airform_graph::build_graph(&manifest).expect("graph build failed");
        let ctx = setup_context(&load_state);

        group.bench_function(*name, |b| {
            b.iter(|| {
                let mut manifest_clone = manifest.clone();
                let compiler = airform_compiler::Compiler::new(setup_engine(&load_state));
                compiler
                    .compile(&mut manifest_clone, &graph, &ctx)
                    .expect("compile failed");
            });
        });
    }

    group.finish();
}

// ---------------------------------------------------------------------------
// Full pipeline benchmarks (load + parse + graph + compile)
// ---------------------------------------------------------------------------

fn bench_full_pipeline(c: &mut Criterion) {
    let mut group = c.benchmark_group("full_pipeline");

    for name in &["jaffle-shop", "ecommerce-analytics"] {
        let path = project_path(name);
        if !path.exists() {
            continue;
        }

        group.bench_function(*name, |b| {
            b.iter(|| {
                // Load
                let load_state = airform_loader::load(&path).expect("load failed");

                // Setup engine with macros
                let engine = setup_engine(&load_state);

                // Parse
                let mut manifest =
                    airform_parser::parse(&load_state, &engine).expect("parse failed");

                // Graph
                let graph = airform_graph::build_graph(&manifest).expect("graph build failed");

                // Compile
                let ctx = setup_context(&load_state);
                let compiler = airform_compiler::Compiler::new(engine);
                compiler
                    .compile(&mut manifest, &graph, &ctx)
                    .expect("compile failed");
            });
        });
    }

    group.finish();
}

criterion_group!(
    benches,
    bench_load,
    bench_parse,
    bench_graph,
    bench_compile,
    bench_full_pipeline,
);
criterion_main!(benches);
