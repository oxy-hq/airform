use airform_executor::{Executor, NodeStatus};
use colored::Colorize;
use std::path::Path;
use std::time::Instant;

pub async fn run(project_dir: &Path) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Loading seeds...".cyan());

    // Load
    let load_state = airform_loader::load(project_dir)?;

    // Parse (we need the manifest to know about seeds)
    let engine = airform_jinja::JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine)?;

    // Execute seed loading
    let executor = Executor::new();
    let seed_results = executor.load_seeds(&manifest).await?;

    let duration = start.elapsed();

    // Print results
    println!();
    for result in &seed_results {
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

    let success = seed_results.iter().filter(|r| r.status == NodeStatus::Success).count();
    let errors = seed_results.iter().filter(|r| r.status == NodeStatus::Error).count();

    println!();
    println!(
        "{}",
        format!(
            "Done. {} seeds loaded, {} errors in {:.2}s",
            success,
            errors,
            duration.as_secs_f64()
        )
        .bold()
    );

    if errors > 0 {
        std::process::exit(1);
    }

    Ok(())
}
