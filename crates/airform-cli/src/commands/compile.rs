use colored::Colorize;
use std::path::Path;
use std::time::Instant;

pub fn run(
    project_dir: &Path,
    select: Option<&str>,
    exclude: Option<&str>,
    format: &str,
    target_override: Option<&str>,
    no_cache: bool,
) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Compiling project...".cyan());

    // Load (with optional target override)
    let load_state = airform_loader::load_with_target(project_dir, target_override)?;

    // Load cache for incremental builds
    let target_dir_path = project_dir.join(&load_state.project.target_path);
    let cache = if no_cache {
        airform_core::FileCache::default()
    } else {
        airform_core::FileCache::load(&target_dir_path)
    };

    // Build Jinja context from target
    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    ctx.populate_vars(&load_state.project.vars);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }

    // Parse with custom macros loaded
    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String, Option<String>)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone(), m.package.clone()))
        .collect();
    engine.load_macros_with_packages(&macro_defs);

    let mut manifest = airform_parser::parse(&load_state, &engine)?;

    // Log cache status
    if !no_cache {
        let mut unchanged = 0;
        for node in manifest.nodes.values() {
            if let airform_core::ManifestNode::Model(m) = node {
                let file_key = m.original_file_path.to_string_lossy().to_string();
                if !cache.is_changed(&file_key, &m.raw_sql) {
                    unchanged += 1;
                }
            }
        }
        if unchanged > 0 {
            tracing::info!("{unchanged} models unchanged (cached)");
        }
    }

    // Build graph
    let graph = airform_graph::build_graph(&manifest)?;

    // Compile
    let compiler = airform_compiler::Compiler::new(engine);
    let result = compiler.compile(&mut manifest, &graph, &ctx)?;

    let duration = start.elapsed();

    let is_machine = format == "json" || format == "csv";

    if is_machine {
        print_results_machine(&result, format, duration)?;
    } else {
        // Print results
        println!();
        if result.errors.is_empty() {
            println!("{}", format!("Compilation complete! {result}").green().bold());
        } else {
            println!("{}", "Compilation finished with errors:".yellow().bold());
            for err in &result.errors {
                println!("  {} {}: {}", "ERROR".red(), err.node_id, err.message);
            }
        }
        println!("  Elapsed: {:.2}s", duration.as_secs_f64());

        // If select is provided, show compiled SQL for selected models
        if let Some(select) = select {
            println!();
            let criteria = airform_graph::selector::parse_selection(select);
            let selector = airform_graph::NodeSelector::new(&manifest, &graph);
            let mut selected = selector.select(&criteria);

            // Subtract excluded nodes
            if let Some(exclude) = exclude {
                let exclude_criteria = airform_graph::selector::parse_selection(exclude);
                let excluded = selector.select(&exclude_criteria);
                let excluded_set: std::collections::HashSet<_> = excluded.into_iter().collect();
                selected.retain(|id| !excluded_set.contains(id));
            }

            for id in &selected {
                if let Some(airform_core::ManifestNode::Model(m)) = manifest.nodes.get(id) {
                    println!("{} {}", "-- Model:".dimmed(), m.name.bold());
                    if let Some(sql) = &m.compiled_sql {
                        println!("{sql}");
                    } else {
                        println!("{}", "(not compiled)".dimmed());
                    }
                    println!();
                }
            }
        }
    }

    // Update cache with current file hashes
    let mut new_cache = airform_core::FileCache::default();
    for node in manifest.nodes.values() {
        if let airform_core::ManifestNode::Model(m) = node {
            let file_key = m.original_file_path.to_string_lossy().to_string();
            new_cache.update(&file_key, &m.raw_sql);
        }
    }
    let _ = new_cache.save(&target_dir_path);

    // Write compiled manifest to target/
    std::fs::create_dir_all(&target_dir_path)?;

    // Write compiled SQL files
    let compiled_dir = target_dir_path.join("compiled").join(&load_state.project.name);
    std::fs::create_dir_all(&compiled_dir)?;

    for node in manifest.nodes.values() {
        if let airform_core::ManifestNode::Model(m) = node {
            if let Some(sql) = &m.compiled_sql {
                let out_path = compiled_dir.join(&m.path);
                if let Some(parent) = out_path.parent() {
                    std::fs::create_dir_all(parent)?;
                }
                std::fs::write(&out_path, sql)?;
            }
        }
    }

    // Write manifest.json
    let manifest_path = target_dir_path.join("manifest.json");
    std::fs::write(&manifest_path, serde_json::to_string_pretty(&manifest)?)?;
    tracing::info!("Wrote {}", manifest_path.display());

    Ok(())
}

fn print_results_machine(
    result: &airform_compiler::CompileResult,
    format: &str,
    duration: std::time::Duration,
) -> anyhow::Result<()> {
    match format {
        "json" => {
            let errors: Vec<serde_json::Value> = result
                .errors
                .iter()
                .map(|e| {
                    serde_json::json!({
                        "node_id": e.node_id,
                        "message": e.message,
                    })
                })
                .collect();
            let output = serde_json::json!({
                "compiled_count": result.compiled_count,
                "error_count": result.errors.len(),
                "errors": errors,
                "elapsed_secs": duration.as_secs_f64(),
            });
            println!("{}", serde_json::to_string_pretty(&output)?);
        }
        "csv" => {
            println!("compiled_count,error_count,elapsed_secs");
            println!(
                "{},{},{:.4}",
                result.compiled_count,
                result.errors.len(),
                duration.as_secs_f64()
            );
        }
        _ => {}
    }
    Ok(())
}
