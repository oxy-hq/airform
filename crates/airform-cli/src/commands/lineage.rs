use colored::Colorize;
use std::path::Path;

pub fn run(
    project_dir: &Path,
    model: &str,
    upstream: bool,
    downstream: bool,
    column: Option<&str>,
) -> anyhow::Result<()> {
    let load_state = airform_loader::load(project_dir)?;
    let mut engine = airform_jinja::JinjaEngine::new();

    // Load custom macros
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

    let mut manifest = airform_parser::parse(&load_state, &engine)?;
    let graph = airform_graph::build_graph(&manifest)?;

    // Find the model
    let model_id = manifest
        .nodes
        .values()
        .find(|n| n.name() == model)
        .map(|n| n.unique_id().to_string())
        .ok_or_else(|| anyhow::anyhow!("Model '{model}' not found"))?;

    // If --column is specified, compile first for accurate lineage, then show column-level lineage
    if let Some(col_name) = column {
        // Compile to get resolved SQL for accurate lineage
        let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
        ctx.populate_vars(&load_state.project.vars);
        if let Some(target) = &load_state.target {
            ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
            ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
            ctx.target_type = target.adapter_type.clone();
        }
        let compile_engine = airform_jinja::JinjaEngine::new();
        let compiler = airform_compiler::Compiler::new(compile_engine);
        let _ = compiler.compile(&mut manifest, &graph, &ctx);

        println!(
            "{} {}.{}",
            "Column lineage for:".bold(),
            model.cyan(),
            col_name.cyan()
        );

        let col_lineage = airform_graph::build_column_lineage(&manifest);
        let trace = col_lineage.trace_column(model, col_name);

        if trace.is_empty() {
            println!();
            println!("  {}", "(no column lineage found)".dimmed());
            println!(
                "  {}",
                "Hint: lineage requires schema.yml column definitions and compiled SQL."
                    .dimmed()
            );
        } else {
            println!();
            println!(
                "  {:30} {:20} {:10} {:30} {}",
                "SOURCE NODE".bold(),
                "SOURCE COLUMN".bold(),
                "TYPE".bold(),
                "TARGET NODE".bold(),
                "TARGET COLUMN".bold()
            );
            println!("  {}", "-".repeat(100));
            for edge in &trace {
                let dep_type = match edge.dependency_type {
                    airform_graph::DependencyType::Copy => "copy".green(),
                    airform_graph::DependencyType::Transform => "transform".yellow(),
                    airform_graph::DependencyType::Scan => "scan".dimmed(),
                };
                println!(
                    "  {:30} {:20} {:10} {:30} {}",
                    edge.source_node,
                    edge.source_column,
                    dep_type,
                    edge.target_node,
                    edge.target_column
                );
            }
        }

        return Ok(());
    }

    // Table-level lineage (existing behavior)
    println!("{} {}", "Lineage for:".bold(), model.cyan());

    let show_both = !upstream && !downstream;

    if upstream || show_both {
        let parents = graph.ancestors(&model_id);
        println!();
        println!("{}", "  Upstream dependencies:".bold());
        if parents.is_empty() {
            println!("    (none)");
        } else {
            for p in &parents {
                let node_name = manifest
                    .nodes
                    .get(p)
                    .map(|n| n.name().to_string())
                    .or_else(|| {
                        manifest.sources.get(p).map(|s| {
                            format!("source:{}.{}", s.source_name, s.name)
                        })
                    })
                    .unwrap_or_else(|| p.clone());
                let is_direct = graph.parents(&model_id).contains(p);
                let marker = if is_direct { ">" } else { " " };
                println!("    {marker} {node_name}");
            }
        }
    }

    if downstream || show_both {
        let children = graph.descendants(&model_id);
        println!();
        println!("{}", "  Downstream dependents:".bold());
        if children.is_empty() {
            println!("    (none)");
        } else {
            for c in &children {
                let node_name = manifest
                    .nodes
                    .get(c)
                    .map(|n| n.name().to_string())
                    .unwrap_or_else(|| c.clone());
                let is_direct = graph.children(&model_id).contains(c);
                let marker = if is_direct { ">" } else { " " };
                println!("    {marker} {node_name}");
            }
        }
    }

    Ok(())
}
