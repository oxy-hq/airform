use airform_core::ManifestNode;
use airform_executor::{Executor, NodeStatus};
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
    println!("{}", "Running snapshots...".cyan());

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

    // Filter to only snapshot nodes
    let snapshot_ids: Vec<String> = manifest
        .nodes
        .iter()
        .filter(|(_, node)| matches!(node, ManifestNode::Snapshot(_)))
        .map(|(id, _)| id.clone())
        .collect();

    // If user provided a --select filter, intersect with snapshot nodes
    let mut selected: Vec<String> = if let Some(select) = select {
        let criteria = parse_selection(select);
        let selector = NodeSelector::new(&manifest, &graph);
        let user_selected: Vec<String> = selector.select(&criteria).iter().map(|s| s.to_string()).collect();
        snapshot_ids
            .into_iter()
            .filter(|id| user_selected.contains(id))
            .collect()
    } else {
        snapshot_ids
    };

    // Subtract excluded nodes
    if let Some(exclude) = exclude {
        let exclude_criteria = parse_selection(exclude);
        let selector = NodeSelector::new(&manifest, &graph);
        let excluded: std::collections::HashSet<String> = selector
            .select(&exclude_criteria)
            .into_iter()
            .map(|s| s.to_string())
            .collect();
        selected.retain(|id| !excluded.contains(id));
    }

    if selected.is_empty() {
        println!("{}", "No snapshot nodes found.".yellow());
        return Ok(());
    }

    println!(
        "{}",
        format!("Found {} snapshot(s) to execute.", selected.len()).dimmed()
    );

    // Execute
    let executor = Executor::new();

    // Register information schema tables
    if let Err(e) = airform_executor::register_info_schema(executor.session_context(), &manifest, &graph) {
        tracing::debug!("Could not register info schema: {e}");
    }

    // Load seeds (snapshots may depend on seed data)
    let seed_results = executor.load_seeds(&manifest).await?;
    for sr in &seed_results {
        if sr.status == NodeStatus::Error {
            tracing::warn!("Seed '{}' failed to load: {:?}", sr.name, sr.message);
        }
    }

    // Execute only snapshot nodes
    let selected_refs: Vec<&str> = selected.iter().map(|s| s.as_str()).collect();
    let exec_result = executor
        .execute(&manifest, &graph, Some(&selected_refs))
        .await?;

    let duration = start.elapsed();

    // Print results
    let is_machine = format == "json" || format == "csv";

    if is_machine {
        print_results_machine(&exec_result, format, duration)?;
    } else {
        println!();
        for result in &exec_result.results {
            let status_colored = match result.status {
                NodeStatus::Success => "OK".green(),
                NodeStatus::Error => "ERROR".red(),
                NodeStatus::Skipped => "SKIP".yellow(),
            };

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
                "  {} {}{}{} [{:.2}s]",
                status_colored,
                result.name.bold(),
                rows,
                msg.dimmed(),
                result.duration.as_secs_f64()
            );
        }

        println!();
        println!(
            "{}",
            format!(
                "Done. {} succeeded, {} errored, {} skipped in {:.2}s",
                exec_result.success_count(),
                exec_result.error_count(),
                exec_result.skipped_count(),
                duration.as_secs_f64()
            )
            .bold()
        );
    }

    if exec_result.error_count() > 0 {
        std::process::exit(1);
    }

    Ok(())
}

fn print_results_machine(
    exec_result: &airform_executor::ExecutionResult,
    format: &str,
    duration: std::time::Duration,
) -> anyhow::Result<()> {
    match format {
        "json" => {
            let results: Vec<serde_json::Value> = exec_result
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
            let output = serde_json::json!({
                "results": results,
                "elapsed_secs": duration.as_secs_f64(),
                "success_count": exec_result.success_count(),
                "error_count": exec_result.error_count(),
                "skipped_count": exec_result.skipped_count(),
            });
            println!("{}", serde_json::to_string_pretty(&output)?);
        }
        "csv" => {
            println!("unique_id,name,status,duration_secs,rows_affected,message");
            for r in &exec_result.results {
                println!(
                    "{},{},{},{:.4},{},{}",
                    r.unique_id,
                    r.name,
                    r.status,
                    r.duration.as_secs_f64(),
                    r.rows_affected.map(|v| v.to_string()).unwrap_or_default(),
                    r.message.as_deref().unwrap_or(""),
                );
            }
        }
        _ => {}
    }
    Ok(())
}
