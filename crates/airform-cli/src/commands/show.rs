use colored::Colorize;
use std::path::Path;

use super::common;

pub async fn run(
    project_dir: &Path,
    select: &str,
    limit: usize,
    target_override: Option<&str>,
) -> anyhow::Result<()> {
    println!("{}", format!("Previewing: {select}").cyan());

    let output = common::load_and_compile(project_dir, target_override, false)?;
    let manifest = output.manifest;
    let graph = output.graph;

    // Execute seeds + models
    let executor = common::create_executor(&output.load_state, &output.target_schema).await?;
    executor.load_seeds(&manifest).await?;
    executor.execute(&manifest, &graph, None).await?;

    // Validate the model name is a safe identifier (prevent SQL injection)
    if !select
        .chars()
        .all(|c| c.is_ascii_alphanumeric() || c == '_' || c == '.')
    {
        anyhow::bail!(
            "Invalid model name '{}': must contain only alphanumeric characters, underscores, and dots",
            select
        );
    }

    // Query the selected model
    let query = format!("SELECT * FROM {select} LIMIT {limit}");
    match executor.execute_query(&query).await {
        Ok(result) => {
            print!("{}", result.format_table());
        }
        Err(e) => {
            println!("{} {}", "Error:".red(), e);
            std::process::exit(1);
        }
    }

    Ok(())
}
