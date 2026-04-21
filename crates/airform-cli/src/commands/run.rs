use airform_executor::{NodeStatus, QueryResult};
use colored::Colorize;
use std::path::Path;
use std::time::Instant;

use super::common;

pub async fn run(
    project_dir: &Path,
    select: Option<&str>,
    exclude: Option<&str>,
    query: Option<&str>,
    format: &str,
    target_override: Option<&str>,
    full_refresh: bool,
) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Running models...".cyan());

    let output = common::load_and_compile(project_dir, target_override, full_refresh)?;
    let load_state = output.load_state;
    let manifest = output.manifest;
    let graph = output.graph;

    let selected = common::apply_selection(&manifest, &graph, select, exclude);

    // Execute - load seeds first, then models
    let executor = common::create_executor(&load_state, &output.target_schema).await?;

    // Register information schema tables
    if let Err(e) = executor.register_info_schema(&manifest, &graph).await {
        tracing::debug!("Could not register info schema: {e}");
    }

    // Load seeds before model execution
    let seed_results = executor.load_seeds(&manifest).await?;
    for sr in &seed_results {
        if sr.status == NodeStatus::Error {
            tracing::warn!("Seed '{}' failed to load: {:?}", sr.name, sr.message);
        }
    }

    let exec_result = executor
        .execute(&manifest, &graph, selected.as_deref())
        .await?;

    let duration = start.elapsed();

    // Handle ad-hoc query mode
    if let Some(query_sql) = query {
        println!();
        println!("{}", format!("Running query: {query_sql}").dimmed());
        match executor.execute_query(query_sql).await {
            Ok(result) => {
                print_query_results(&result, format)?;
            }
            Err(e) => {
                println!("{} {}", "Query error:".red(), e);
                std::process::exit(1);
            }
        }
        return Ok(());
    }

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

    // Write artifacts
    common::write_run_results(project_dir, &load_state.project, &exec_result, duration)?;
    common::write_manifest(project_dir, &load_state.project, &manifest)?;
    common::write_compiled_sql(project_dir, &load_state.project, &manifest)?;

    if exec_result.error_count() > 0 {
        std::process::exit(1);
    }

    Ok(())
}

fn print_query_results(result: &QueryResult, format: &str) -> anyhow::Result<()> {
    if result.rows.is_empty() {
        println!("(no results)");
        return Ok(());
    }

    match format {
        "json" => {
            let rows: Vec<serde_json::Value> = result
                .rows
                .iter()
                .map(|row| {
                    let mut obj = serde_json::Map::new();
                    for (i, col) in result.columns.iter().enumerate() {
                        obj.insert(
                            col.clone(),
                            row.get(i).cloned().unwrap_or(serde_json::Value::Null),
                        );
                    }
                    serde_json::Value::Object(obj)
                })
                .collect();
            println!("{}", serde_json::to_string_pretty(&rows)?);
        }
        "csv" => {
            println!("{}", result.columns.join(","));
            for row in &result.rows {
                let vals: Vec<String> = row
                    .iter()
                    .map(|v| match v {
                        serde_json::Value::Null => String::new(),
                        serde_json::Value::String(s) => s.clone(),
                        v => v.to_string(),
                    })
                    .collect();
                println!("{}", vals.join(","));
            }
        }
        _ => {
            // Table format
            print!("{}", result.format_table());
        }
    }

    Ok(())
}
