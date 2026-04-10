use colored::Colorize;
use std::path::Path;

pub async fn run(
    project_dir: &Path,
    _select: Option<&str>,
    target_override: Option<&str>,
) -> anyhow::Result<()> {
    println!("{}", "Checking source freshness...".cyan());

    let load_state = airform_loader::load_with_target(project_dir, target_override)?;

    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

    let manifest = airform_parser::parse(&load_state, &engine)?;

    // Check sources with loaded_at_field defined
    let mut checked = 0;
    for node in manifest.nodes.values() {
        if let airform_core::ManifestNode::Source(src) = node {
            if let Some(ref loaded_at) = src.loaded_at_field {
                println!(
                    "  {} source {}.{} (loaded_at: {})",
                    "CHECK".cyan(),
                    src.source_name,
                    src.name,
                    loaded_at
                );
                checked += 1;
            }
        }
    }

    if checked == 0 {
        println!(
            "{}",
            "No sources with loaded_at_field defined. Nothing to check.".yellow()
        );
    } else {
        // Note: actual freshness querying (MAX(loaded_at_field) against warn/error
        // thresholds) requires a warehouse connection and is not yet implemented
        // for the local DataFusion executor.
        println!(
            "{}",
            format!("Found {checked} source(s) with freshness config (freshness querying not yet supported in local mode).").yellow()
        );
    }

    Ok(())
}
