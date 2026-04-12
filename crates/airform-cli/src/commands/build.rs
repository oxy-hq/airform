use airform_executor::{Executor, NodeStatus, TestStatus};
use colored::Colorize;
use std::path::Path;
use std::time::Instant;

use super::common;

pub async fn run(
    project_dir: &Path,
    select: Option<&str>,
    exclude: Option<&str>,
    format: &str,
    target_override: Option<&str>,
    full_refresh: bool,
) -> anyhow::Result<()> {
    let start = Instant::now();
    println!(
        "{}",
        "Building project (seeds → models → snapshots → tests)...".cyan()
    );

    let output = common::load_and_compile(project_dir, target_override, full_refresh)?;
    let load_state = output.load_state;
    let manifest = output.manifest;
    let graph = output.graph;

    let selected = common::apply_selection(&manifest, &graph, select, exclude);

    // Execute
    let executor = Executor::new(&output.target_schema);

    // Register information schema tables
    if let Err(e) =
        airform_executor::register_info_schema(executor.session_context(), &manifest, &graph)
    {
        tracing::debug!("Could not register info schema: {e}");
    }

    // 1. Load seeds
    println!("{}", "Loading seeds...".dimmed());
    let seed_results = executor.load_seeds(&manifest).await?;
    for sr in &seed_results {
        if sr.status == NodeStatus::Error {
            tracing::warn!("Seed '{}' failed to load: {:?}", sr.name, sr.message);
        }
    }

    // 2. Execute models (and snapshots, since execute handles both)
    println!("{}", "Running models and snapshots...".dimmed());
    let exec_result = executor
        .execute(&manifest, &graph, selected.as_deref())
        .await?;

    // Print model/snapshot results
    let is_machine = format == "json" || format == "csv";

    if !is_machine {
        println!();
        println!("{}", "Model results:".bold());
        for result in &exec_result.results {
            let status_colored = match result.status {
                NodeStatus::Success => "OK".green(),
                NodeStatus::Error => "ERROR".red(),
                NodeStatus::Skipped => "SKIP".yellow(),
            };

            let materialization = manifest
                .nodes
                .get(&result.unique_id)
                .and_then(|n| n.materialization())
                .map(|m| format!(" ({m})"))
                .unwrap_or_default();

            let rows = result
                .rows_affected
                .map(|r| format!(" [{r} rows]"))
                .unwrap_or_default();

            let msg = result
                .message
                .as_deref()
                .map(|m| format!(" - {m}"))
                .unwrap_or_default();

            println!(
                "  {} {}{}{}{} [{:.2}s]",
                status_colored,
                result.name.bold(),
                materialization.dimmed(),
                rows,
                msg.dimmed(),
                result.duration.as_secs_f64()
            );
        }
    }

    // 3. Run tests
    println!();
    if !is_machine {
        println!("{}", "Test results:".bold());
    }
    let test_results = executor.execute_tests(&manifest).await?;
    let duration = start.elapsed();

    let mut pass_count = 0;
    let mut fail_count = 0;
    let mut test_error_count = 0;

    if !is_machine {
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
                    test_error_count += 1;
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
    } else {
        for result in &test_results {
            match result.status {
                TestStatus::Pass => pass_count += 1,
                TestStatus::Fail => fail_count += 1,
                TestStatus::Error => test_error_count += 1,
            }
        }
    }

    // Print summary
    if is_machine {
        common::print_exec_results_machine(
            &exec_result,
            Some(&test_results),
            format,
            duration,
        )?;
    } else {
        println!();
        println!(
            "{}",
            format!(
                "Done. Models: {} succeeded, {} errored, {} skipped. Tests: {} passed, {} failed, {} errors. Total: {:.2}s",
                exec_result.success_count(),
                exec_result.error_count(),
                exec_result.skipped_count(),
                pass_count,
                fail_count,
                test_error_count,
                duration.as_secs_f64()
            )
            .bold()
        );
    }

    // Write artifacts
    common::write_run_results(project_dir, &load_state.project, &exec_result, duration)?;
    common::write_manifest(project_dir, &load_state.project, &manifest)?;
    common::write_compiled_sql(project_dir, &load_state.project, &manifest)?;

    if exec_result.error_count() > 0 || fail_count > 0 || test_error_count > 0 {
        std::process::exit(1);
    }

    Ok(())
}
