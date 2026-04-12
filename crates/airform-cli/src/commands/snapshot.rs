use airform_core::ManifestNode;
use airform_executor::{Executor, NodeStatus};
use airform_graph::selector::parse_selection;
use airform_graph::NodeSelector;
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
    println!("{}", "Running snapshots...".cyan());

    let output = common::load_and_compile(project_dir, target_override, full_refresh)?;
    let manifest = output.manifest;
    let graph = output.graph;

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
        let user_selected: Vec<String> = selector
            .select(&criteria)
            .iter()
            .map(|s| s.to_string())
            .collect();
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
    let executor = Executor::new(&output.target_schema);

    // Register information schema tables
    if let Err(e) =
        airform_executor::register_info_schema(executor.session_context(), &manifest, &graph)
    {
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
    let exec_result = executor
        .execute(&manifest, &graph, Some(&selected))
        .await?;

    let duration = start.elapsed();

    // Print results
    let is_machine = format == "json" || format == "csv";

    if is_machine {
        common::print_exec_results_machine(&exec_result, None, format, duration)?;
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
