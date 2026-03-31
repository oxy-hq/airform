use airform_core::ManifestNode;
use colored::Colorize;
use std::path::Path;

pub fn run(
    project_dir: &Path,
    resource_type: Option<&str>,
    output: &str,
    _select: Option<&str>,
) -> anyhow::Result<()> {
    let load_state = airform_loader::load(project_dir)?;
    let engine = airform_jinja::JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine)?;

    // Collect items to display
    let mut items: Vec<LsItem> = Vec::new();

    for (id, node) in &manifest.nodes {
        let (rt, name, mat, path) = match node {
            ManifestNode::Model(m) => (
                "model",
                &m.name,
                Some(m.config.materialized.to_string()),
                Some(m.path.to_string_lossy().to_string()),
            ),
            ManifestNode::Seed(s) => ("seed", &s.name, None, Some(s.path.to_string_lossy().to_string())),
            ManifestNode::Test(t) => ("test", &t.name, None, None),
            ManifestNode::Snapshot(s) => (
                "snapshot",
                &s.name,
                None,
                Some(s.path.to_string_lossy().to_string()),
            ),
            ManifestNode::Source(s) => ("source", &s.name, None, None),
        };

        if let Some(filter) = resource_type {
            if rt != filter {
                continue;
            }
        }

        items.push(LsItem {
            resource_type: rt.to_string(),
            name: name.clone(),
            materialization: mat,
            path,
            unique_id: id.clone(),
        });
    }

    // Also include sources
    for (id, source) in &manifest.sources {
        if resource_type.is_some_and(|rt| rt != "source") {
            continue;
        }
        items.push(LsItem {
            resource_type: "source".to_string(),
            name: format!("{}.{}", source.source_name, source.name),
            materialization: None,
            path: None,
            unique_id: id.clone(),
        });
    }

    items.sort_by(|a, b| a.resource_type.cmp(&b.resource_type).then(a.name.cmp(&b.name)));

    match output {
        "json" => {
            let json: Vec<serde_json::Value> = items
                .iter()
                .map(|item| {
                    serde_json::json!({
                        "resource_type": item.resource_type,
                        "name": item.name,
                        "materialization": item.materialization,
                        "path": item.path,
                        "unique_id": item.unique_id,
                    })
                })
                .collect();
            println!("{}", serde_json::to_string_pretty(&json)?);
        }
        "csv" => {
            println!("resource_type,name,materialization,path,unique_id");
            for item in &items {
                println!(
                    "{},{},{},{},{}",
                    item.resource_type,
                    item.name,
                    item.materialization.as_deref().unwrap_or(""),
                    item.path.as_deref().unwrap_or(""),
                    item.unique_id,
                );
            }
        }
        "name" => {
            for item in &items {
                println!("{}", item.unique_id);
            }
        }
        _ => {
            // Table output
            println!(
                "  {} {:30} {:15} {}",
                "TYPE".bold(),
                "NAME".bold(),
                "MATERIALIZED".bold(),
                "PATH".bold()
            );
            println!("  {}", "-".repeat(80));
            for item in &items {
                let type_colored = match item.resource_type.as_str() {
                    "model" => item.resource_type.cyan(),
                    "source" => item.resource_type.green(),
                    "test" => item.resource_type.yellow(),
                    "seed" => item.resource_type.magenta(),
                    _ => item.resource_type.normal(),
                };
                println!(
                    "  {:8} {:30} {:15} {}",
                    type_colored,
                    item.name,
                    item.materialization.as_deref().unwrap_or("-"),
                    item.path.as_deref().unwrap_or("-")
                );
            }
            println!();
            println!("  {} resources", items.len());
        }
    }

    Ok(())
}

struct LsItem {
    resource_type: String,
    name: String,
    materialization: Option<String>,
    path: Option<String>,
    unique_id: String,
}
