use colored::Colorize;
use std::path::Path;
use std::time::Instant;

pub fn run(project_dir: &Path) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Parsing project...".cyan());

    let load_state = airform_loader::load(project_dir)?;
    let engine = airform_jinja::JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine)?;

    let model_count = manifest
        .nodes
        .values()
        .filter(|n| matches!(n, airform_core::ManifestNode::Model(_)))
        .count();
    let source_count = manifest.sources.len();

    let duration = start.elapsed();

    println!();
    println!("{}", "Parse complete!".green().bold());
    println!(
        "  Found {} models, {} sources in {:.2}s",
        model_count,
        source_count,
        duration.as_secs_f64()
    );

    // Validate DAG
    let graph = airform_graph::build_graph(&manifest)?;
    match graph.topological_sort() {
        Ok(order) => {
            println!(
                "  DAG validated: {} nodes, {} edges",
                graph.node_count(),
                graph.edge_count()
            );
            let _ = order;
        }
        Err(e) => {
            println!("  {} {}", "DAG error:".red().bold(), e);
            return Err(e.into());
        }
    }

    Ok(())
}
