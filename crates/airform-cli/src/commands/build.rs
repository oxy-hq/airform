use airform_executor::{Executor, NodeStatus, TestStatus};
use airform_graph::selector::parse_selection;
use airform_graph::NodeSelector;
use colored::Colorize;
use std::path::Path;
use std::time::Instant;

pub async fn run(
    project_dir: &Path,
    select: Option<&str>,
    exclude: Option<&str>,
    format: &str,
    target_override: Option<&str>,
    full_refresh: bool,
) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Building project (seeds → models → snapshots → tests)...".cyan());

    // Load (with optional target override)
    let load_state = airform_loader::load_with_target(project_dir, target_override)?;

    // Build context
    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }
    ctx.full_refresh = full_refresh;

    // Parse with custom macros
    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

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
        anyhow::bail!("Compilation failed with {} errors", compile_result.errors.len());
    }

    // Determine selection
    let selected = if let Some(select) = select {
        let criteria = parse_selection(select);
        let selector = NodeSelector::new(&manifest, &graph);
        let mut selected = selector.select(&criteria);

        if let Some(exclude) = exclude {
            let exclude_criteria = parse_selection(exclude);
            let excluded = selector.select(&exclude_criteria);
            let excluded_set: std::collections::HashSet<_> = excluded.into_iter().collect();
            selected.retain(|id| !excluded_set.contains(id));
        }

        Some(selected)
    } else if let Some(exclude) = exclude {
        let selector = NodeSelector::new(&manifest, &graph);
        let mut selected = selector.select(&airform_graph::selector::SelectionCriteria::All);
        let exclude_criteria = parse_selection(exclude);
        let excluded = selector.select(&exclude_criteria);
        let excluded_set: std::collections::HashSet<_> = excluded.into_iter().collect();
        selected.retain(|id| !excluded_set.contains(id));
        Some(selected)
    } else {
        None
    };

    // Execute
    let executor = Executor::new();

    // Register information schema tables
    if let Err(e) = airform_executor::register_info_schema(executor.session_context(), &manifest, &graph) {
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
        print_results_machine(&exec_result, &test_results, format, duration)?;
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

    // Write run_results.json
    write_run_results(project_dir, &load_state.project, &exec_result, duration)?;

    // Write manifest.json
    write_manifest(project_dir, &load_state.project, &manifest)?;

    // Write compiled SQL files
    write_compiled_sql(project_dir, &load_state.project, &manifest)?;

    if exec_result.error_count() > 0 || fail_count > 0 || test_error_count > 0 {
        std::process::exit(1);
    }

    Ok(())
}

fn print_results_machine(
    exec_result: &airform_executor::ExecutionResult,
    test_results: &[airform_executor::TestResult],
    format: &str,
    duration: std::time::Duration,
) -> anyhow::Result<()> {
    match format {
        "json" => {
            let model_results: Vec<serde_json::Value> = exec_result
                .results
                .iter()
                .map(|r| {
                    serde_json::json!({
                        "unique_id": r.unique_id,
                        "name": r.name,
                        "status": r.status.to_string(),
                        "duration_secs": r.duration.as_secs_f64(),
                        "rows_affected": r.rows_affected,
                        "message": r.message,
                    })
                })
                .collect();
            let test_json: Vec<serde_json::Value> = test_results
                .iter()
                .map(|r| {
                    serde_json::json!({
                        "test_name": r.test_name,
                        "status": format!("{:?}", r.status),
                        "failures": r.failures,
                        "duration_secs": r.duration.as_secs_f64(),
                        "message": r.message,
                    })
                })
                .collect();
            let output = serde_json::json!({
                "results": model_results,
                "test_results": test_json,
                "elapsed_secs": duration.as_secs_f64(),
                "success_count": exec_result.success_count(),
                "error_count": exec_result.error_count(),
                "skipped_count": exec_result.skipped_count(),
            });
            println!("{}", serde_json::to_string_pretty(&output)?);
        }
        "csv" => {
            println!("type,unique_id,name,status,duration_secs,rows_affected,message");
            for r in &exec_result.results {
                println!(
                    "model,{},{},{},{:.4},{},{}",
                    r.unique_id,
                    r.name,
                    r.status,
                    r.duration.as_secs_f64(),
                    r.rows_affected.map(|v| v.to_string()).unwrap_or_default(),
                    r.message.as_deref().unwrap_or(""),
                );
            }
            for r in test_results {
                println!(
                    "test,,{},{:?},{:.4},,{}",
                    r.test_name,
                    r.status,
                    r.duration.as_secs_f64(),
                    r.message.as_deref().unwrap_or(""),
                );
            }
        }
        _ => {}
    }
    Ok(())
}

fn write_run_results(
    project_dir: &Path,
    project: &airform_core::DbtProject,
    exec_result: &airform_executor::ExecutionResult,
    total_duration: std::time::Duration,
) -> anyhow::Result<()> {
    let target_dir = project_dir.join(&project.target_path);
    std::fs::create_dir_all(&target_dir)?;

    let results: Vec<serde_json::Value> = exec_result
        .results
        .iter()
        .map(|r| {
            serde_json::json!({
                "unique_id": r.unique_id,
                "status": r.status.to_string().to_lowercase(),
                "timing": {
                    "started_at": null,
                    "completed_at": null,
                    "duration_secs": r.duration.as_secs_f64(),
                },
                "adapter_response": {
                    "rows_affected": r.rows_affected,
                },
                "message": r.message,
            })
        })
        .collect();

    let run_results = serde_json::json!({
        "metadata": {
            "project_name": project.name,
            "airform_version": env!("CARGO_PKG_VERSION"),
            "generated_at": chrono::Utc::now().to_rfc3339(),
        },
        "results": results,
        "elapsed_time": total_duration.as_secs_f64(),
    });

    let path = target_dir.join("run_results.json");
    std::fs::write(&path, serde_json::to_string_pretty(&run_results)?)?;
    tracing::info!("Wrote {}", path.display());

    Ok(())
}

fn write_manifest(
    project_dir: &Path,
    project: &airform_core::DbtProject,
    manifest: &airform_core::Manifest,
) -> anyhow::Result<()> {
    let target_dir = project_dir.join(&project.target_path);
    std::fs::create_dir_all(&target_dir)?;

    let path = target_dir.join("manifest.json");
    std::fs::write(&path, serde_json::to_string_pretty(manifest)?)?;
    tracing::info!("Wrote {}", path.display());

    Ok(())
}

fn write_compiled_sql(
    project_dir: &Path,
    project: &airform_core::DbtProject,
    manifest: &airform_core::Manifest,
) -> anyhow::Result<()> {
    let target_dir = project_dir.join(&project.target_path);
    let compiled_dir = target_dir.join("compiled").join(&project.name);
    std::fs::create_dir_all(&compiled_dir)?;

    for node in manifest.nodes.values() {
        if let airform_core::ManifestNode::Model(m) = node {
            if let Some(sql) = &m.compiled_sql {
                let out_path = compiled_dir.join(&m.path);
                if let Some(parent) = out_path.parent() {
                    std::fs::create_dir_all(parent)?;
                }
                std::fs::write(&out_path, sql)?;
            }
        }
    }

    Ok(())
}
