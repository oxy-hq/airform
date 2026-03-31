use airform_executor::{Executor, NodeStatus, TestStatus};
use colored::Colorize;
use std::path::Path;
use std::time::Instant;

pub async fn run(project_dir: &Path, _select: Option<&str>, target_override: Option<&str>) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Running tests...".cyan());

    // Load (with optional target override)
    let load_state = airform_loader::load_with_target(project_dir, target_override)?;

    // Build context
    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }

    // Parse
    let engine = airform_jinja::JinjaEngine::new();
    let mut manifest = airform_parser::parse(&load_state, &engine)?;

    // Build graph
    let graph = airform_graph::build_graph(&manifest)?;

    // Compile
    let compiler = airform_compiler::Compiler::new(engine);
    let compile_result = compiler.compile(&mut manifest, &graph, &ctx)?;

    if !compile_result.errors.is_empty() {
        println!("{}", "Compilation errors:".red().bold());
        for err in &compile_result.errors {
            println!("  {} {}: {}", "ERROR".red(), err.node_id, err.message);
        }
        anyhow::bail!(
            "Compilation failed with {} errors",
            compile_result.errors.len()
        );
    }

    // Execute - first load seeds, then run models, then run tests
    let executor = Executor::new();

    // Load seeds
    let seed_results = executor.load_seeds(&manifest).await?;
    for sr in &seed_results {
        if sr.status == NodeStatus::Error {
            tracing::warn!("Seed '{}' failed to load: {:?}", sr.name, sr.message);
        }
    }

    // Execute models so the tables exist for tests
    let exec_result = executor.execute(&manifest, &graph, None).await?;

    if exec_result.error_count() > 0 {
        println!(
            "{}",
            format!(
                "Warning: {} models had errors during execution",
                exec_result.error_count()
            )
            .yellow()
        );
    }

    // Run tests
    let test_results = executor.execute_tests(&manifest).await?;
    let duration = start.elapsed();

    // Print results
    println!();
    let mut pass_count = 0;
    let mut fail_count = 0;
    let mut error_count = 0;

    for result in &test_results {
        let status_colored = match result.status {
            TestStatus::Pass => {
                pass_count += 1;
                "PASS".green()
            }
            TestStatus::Fail => {
                fail_count += 1;
                "FAIL".red()
            }
            TestStatus::Error => {
                error_count += 1;
                "ERROR".red()
            }
        };

        let failures_info = if result.failures > 0 {
            format!(" ({} failures)", result.failures)
        } else {
            String::new()
        };

        let msg = result
            .message
            .as_deref()
            .map(|m| format!(" - {m}"))
            .unwrap_or_default();

        println!(
            "  {} {}{}{} [{:.2}s]",
            status_colored,
            result.test_name.bold(),
            failures_info,
            msg.dimmed(),
            result.duration.as_secs_f64()
        );
    }

    println!();
    println!(
        "{}",
        format!(
            "Done. {} passed, {} failed, {} errors in {:.2}s",
            pass_count, fail_count, error_count,
            duration.as_secs_f64()
        )
        .bold()
    );

    if fail_count > 0 || error_count > 0 {
        std::process::exit(1);
    }

    Ok(())
}
