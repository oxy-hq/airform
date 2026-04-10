use colored::Colorize;
use std::path::Path;

use super::common;

pub async fn run(
    project_dir: &Path,
    _select: Option<&str>,
    target_override: Option<&str>,
) -> anyhow::Result<()> {
    println!("{}", "Checking source freshness...".cyan());

    let output = common::load_and_compile(project_dir, target_override, false)?;
    let manifest = output.manifest;

    // Count sources
    let source_count = manifest
        .nodes
        .values()
        .filter(|n| matches!(n, airform_core::ManifestNode::Source(_)))
        .count();

    if source_count == 0 {
        println!("{}", "No sources defined. Nothing to check.".yellow());
    } else {
        for node in manifest.nodes.values() {
            if let airform_core::ManifestNode::Source(src) = node {
                println!(
                    "  {} source {}.{}",
                    "FOUND".cyan(),
                    src.source_name,
                    src.name,
                );
            }
        }
        // Note: actual freshness querying (MAX(loaded_at_field) against warn/error
        // thresholds) requires a warehouse connection and is not yet implemented
        // for the local DataFusion executor.
        println!(
            "{}",
            format!("Found {source_count} source(s) (freshness querying not yet supported in local mode).").yellow()
        );
    }

    Ok(())
}
