use airform_core::{DbtProject, Manifest};
use airform_executor::{ExecutionResult, TestResult};
use airform_graph::selector::parse_selection;
use airform_graph::{DbtGraph, NodeSelector};
use colored::Colorize;
use std::collections::HashSet;
use std::path::Path;
use std::time::Duration;

/// Result of the full load → parse → graph → compile pipeline.
pub struct CompileOutput {
    pub load_state: airform_loader::LoadState,
    pub manifest: Manifest,
    pub graph: DbtGraph,
    pub target_schema: String,
}

/// Load, parse, build graph, and compile a dbt project.
/// This is the standard pipeline used by run, build, snapshot, test, and show.
pub fn load_and_compile(
    project_dir: &Path,
    target_override: Option<&str>,
    full_refresh: bool,
) -> anyhow::Result<CompileOutput> {
    let load_state = airform_loader::load_with_target(project_dir, target_override)?;

    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    ctx.populate_vars(&load_state.project.vars);
    let target_schema = if let Some(target) = &load_state.target {
        let schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_schema = schema.clone();
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
        schema
    } else {
        "public".to_string()
    };
    ctx.full_refresh = full_refresh;

    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

    let mut manifest = airform_parser::parse(&load_state, &engine)?;
    let graph = airform_graph::build_graph(&manifest)?;

    let compiler = airform_compiler::Compiler::new(engine);
    let compile_result = compiler.compile(&mut manifest, &graph, &ctx)?;

    if !compile_result.errors.is_empty() {
        println!("{}", "Compilation errors:".red().bold());
        for err in &compile_result.errors {
            println!("  {} {}: {}", "ERROR".red(), err.node_id, err.message);
        }
        anyhow::bail!(
            "Compilation failed with {} errors",
            compile_result.errors.len()
        );
    }

    Ok(CompileOutput {
        load_state,
        manifest,
        graph,
        target_schema,
    })
}

/// Apply --select and --exclude filters, returning None if no filtering requested.
pub fn apply_selection(
    manifest: &Manifest,
    graph: &DbtGraph,
    select: Option<&str>,
    exclude: Option<&str>,
) -> Option<Vec<String>> {
    if let Some(select) = select {
        let criteria = parse_selection(select);
        let selector = NodeSelector::new(manifest, graph);
        let mut selected = selector.select(&criteria);

        if let Some(exclude) = exclude {
            let exclude_criteria = parse_selection(exclude);
            let excluded = selector.select(&exclude_criteria);
            let excluded_set: HashSet<_> = excluded.into_iter().collect();
            selected.retain(|id| !excluded_set.contains(id));
        }

        Some(selected)
    } else if let Some(exclude) = exclude {
        let selector = NodeSelector::new(manifest, graph);
        let mut selected = selector.select(&airform_graph::selector::SelectionCriteria::All);
        let exclude_criteria = parse_selection(exclude);
        let excluded = selector.select(&exclude_criteria);
        let excluded_set: HashSet<_> = excluded.into_iter().collect();
        selected.retain(|id| !excluded_set.contains(id));
        Some(selected)
    } else {
        None
    }
}

/// Write run_results.json to the target directory.
pub fn write_run_results(
    project_dir: &Path,
    project: &DbtProject,
    exec_result: &ExecutionResult,
    total_duration: Duration,
) -> anyhow::Result<()> {
    let target_dir = project_dir.join(&project.target_path);
    std::fs::create_dir_all(&target_dir)?;

    let results: Vec<serde_json::Value> = exec_result
        .results
        .iter()
        .map(|r| {
            serde_json::json!({
                "unique_id": r.unique_id,
                "status": r.status.to_string().to_lowercase(),
                "timing": {
                    "started_at": null,
                    "completed_at": null,
                    "duration_secs": r.duration.as_secs_f64(),
                },
                "adapter_response": {
                    "rows_affected": r.rows_affected,
                },
                "message": r.message,
            })
        })
        .collect();

    let run_results = serde_json::json!({
        "metadata": {
            "project_name": project.name,
            "airform_version": env!("CARGO_PKG_VERSION"),
            "generated_at": chrono::Utc::now().to_rfc3339(),
        },
        "results": results,
        "elapsed_time": total_duration.as_secs_f64(),
    });

    let path = target_dir.join("run_results.json");
    std::fs::write(&path, serde_json::to_string_pretty(&run_results)?)?;
    tracing::info!("Wrote {}", path.display());

    Ok(())
}

/// Write manifest.json to the target directory.
pub fn write_manifest(
    project_dir: &Path,
    project: &DbtProject,
    manifest: &Manifest,
) -> anyhow::Result<()> {
    let target_dir = project_dir.join(&project.target_path);
    std::fs::create_dir_all(&target_dir)?;

    let path = target_dir.join("manifest.json");
    std::fs::write(&path, serde_json::to_string_pretty(manifest)?)?;
    tracing::info!("Wrote {}", path.display());

    Ok(())
}

/// Write compiled SQL files to target/compiled/<project>/.
pub fn write_compiled_sql(
    project_dir: &Path,
    project: &DbtProject,
    manifest: &Manifest,
) -> anyhow::Result<()> {
    let target_dir = project_dir.join(&project.target_path);
    let compiled_dir = target_dir.join("compiled").join(&project.name);
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

    Ok(())
}

/// Print execution results in machine-readable format (json or csv).
/// Optionally includes test results (used by `build`).
pub fn print_exec_results_machine(
    exec_result: &ExecutionResult,
    test_results: Option<&[TestResult]>,
    format: &str,
    duration: Duration,
) -> anyhow::Result<()> {
    match format {
        "json" => {
            let model_results: Vec<serde_json::Value> = exec_result
                .results
                .iter()
                .map(|r| {
                    serde_json::json!({
                        "unique_id": r.unique_id,
                        "name": r.name,
                        "status": r.status.to_string(),
                        "duration_secs": r.duration.as_secs_f64(),
                        "rows_affected": r.rows_affected,
                        "message": r.message,
                    })
                })
                .collect();

            let mut output = serde_json::json!({
                "results": model_results,
                "elapsed_secs": duration.as_secs_f64(),
                "success_count": exec_result.success_count(),
                "error_count": exec_result.error_count(),
                "skipped_count": exec_result.skipped_count(),
            });

            if let Some(tests) = test_results {
                let test_json: Vec<serde_json::Value> = tests
                    .iter()
                    .map(|r| {
                        serde_json::json!({
                            "test_name": r.test_name,
                            "status": format!("{:?}", r.status),
                            "failures": r.failures,
                            "duration_secs": r.duration.as_secs_f64(),
                            "message": r.message,
                        })
                    })
                    .collect();
                output["test_results"] = serde_json::Value::Array(test_json);
            }

            println!("{}", serde_json::to_string_pretty(&output)?);
        }
        "csv" => {
            if test_results.is_some() {
                println!("type,unique_id,name,status,duration_secs,rows_affected,message");
            } else {
                println!("unique_id,name,status,duration_secs,rows_affected,message");
            }
            for r in &exec_result.results {
                if test_results.is_some() {
                    print!("model,");
                }
                println!(
                    "{},{},{},{:.4},{},{}",
                    r.unique_id,
                    r.name,
                    r.status,
                    r.duration.as_secs_f64(),
                    r.rows_affected
                        .map(|v| v.to_string())
                        .unwrap_or_default(),
                    r.message.as_deref().unwrap_or(""),
                );
            }
            if let Some(tests) = test_results {
                for r in tests {
                    println!(
                        "test,,{},{:?},{:.4},,{}",
                        r.test_name,
                        r.status,
                        r.duration.as_secs_f64(),
                        r.message.as_deref().unwrap_or(""),
                    );
                }
            }
        }
        _ => {}
    }
    Ok(())
}
