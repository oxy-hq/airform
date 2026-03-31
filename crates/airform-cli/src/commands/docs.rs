use colored::Colorize;
use std::path::Path;

pub fn run(project_dir: &Path) -> anyhow::Result<()> {
    println!("{}", "Generating documentation...".cyan());

    let load_state = airform_loader::load(project_dir)?;
    let engine = airform_jinja::JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine)?;

    // Write manifest.json
    let target_dir = project_dir.join(&load_state.project.target_path);
    std::fs::create_dir_all(&target_dir)?;

    let manifest_json = serde_json::to_string_pretty(&manifest)?;
    let manifest_path = target_dir.join("manifest.json");
    std::fs::write(&manifest_path, manifest_json)?;

    println!(
        "  {} manifest.json ({} nodes, {} sources)",
        "Wrote".green(),
        manifest.nodes.len(),
        manifest.sources.len()
    );
    println!("  {}", manifest_path.display());

    Ok(())
}
