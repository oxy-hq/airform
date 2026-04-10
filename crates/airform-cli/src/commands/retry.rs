use colored::Colorize;
use std::path::Path;

pub async fn run(project_dir: &Path, target_override: Option<&str>) -> anyhow::Result<()> {
    let target_dir = project_dir.join("target");
    let run_results_path = target_dir.join("run_results.json");

    if !run_results_path.exists() {
        anyhow::bail!(
            "No run_results.json found at {}. Run `airform run` or `airform build` first.",
            run_results_path.display()
        );
    }

    let content = std::fs::read_to_string(&run_results_path)?;
    let run_results: serde_json::Value = serde_json::from_str(&content)?;

    let failed_ids: Vec<&str> = run_results["results"]
        .as_array()
        .map(|arr| {
            arr.iter()
                .filter(|r| r["status"].as_str() == Some("error"))
                .filter_map(|r| r["unique_id"].as_str())
                .collect()
        })
        .unwrap_or_default();

    if failed_ids.is_empty() {
        println!("{}", "No failed nodes to retry.".green());
        return Ok(());
    }

    println!(
        "{}",
        format!("Retrying {} failed node(s)...", failed_ids.len()).cyan()
    );
    for id in &failed_ids {
        println!("  {}", id);
    }

    // Pass full unique_ids as the selector — the selection engine handles unique_id matching
    let select = failed_ids.join(" ");
    super::run::run(
        project_dir,
        Some(&select),
        None,
        None,
        "table",
        target_override,
        false,
    )
    .await
}
