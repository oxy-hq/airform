use airform_executor::{NodeStatus, Executor};
use airform_graph::selector::parse_selection;
use airform_graph::NodeSelector;
use colored::Colorize;
use std::path::Path;
use std::time::Instant;

pub async fn run(
    project_dir: &Path,
    select: Option<&str>,
    _exclude: Option<&str>,
    query: Option<&str>,
    format: &str,
    target_override: Option<&str>,
    full_refresh: bool,
) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Running models...".cyan());

    // Load (with optional target override)
    let load_state = airform_loader::load_with_target(project_dir, target_override)?;

    // Build context
    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }
    ctx.full_refresh = full_refresh;

    // Parse with custom macros
    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

    let mut manifest = airform_parser::parse(&load_state, &engine)?;

    // Build graph
    let graph = airform_graph::build_graph(&manifest)?;

    // Compile
    let compiler = airform_compiler::Compiler::new(engine);
    let compile_result = compiler.compile(&mut manifest, &graph, &ctx)?;

    if !compile_result.errors.is_empty() {
        println!("{}", "Compilation errors:".red().bold());
        for err in &compile_result.errors {
            println!("  {} {}: {}", "ERROR".red(), err.node_id, err.message);
        }
        anyhow::bail!("Compilation failed with {} errors", compile_result.errors.len());
    }

    // Determine selection
    let selected = if let Some(select) = select {
        let criteria = parse_selection(select);
        let selector = NodeSelector::new(&manifest, &graph);
        Some(selector.select(&criteria))
    } else {
        None
    };

    // Execute - load seeds first, then models
    let executor = Executor::new();

    // Register information schema tables
    if let Err(e) = airform_executor::register_info_schema(executor.session_context(), &manifest, &graph) {
        tracing::debug!("Could not register info schema: {e}");
    }

    // Load seeds before model execution
    let seed_results = executor.load_seeds(&manifest).await?;
    for sr in &seed_results {
        if sr.status == NodeStatus::Error {
            tracing::warn!("Seed '{}' failed to load: {:?}", sr.name, sr.message);
        }
    }

    let exec_result = executor
        .execute(&manifest, &graph, selected.as_deref())
        .await?;

    let duration = start.elapsed();

    // Handle ad-hoc query mode
    if let Some(query_sql) = query {
        println!();
        println!("{}", format!("Running query: {query_sql}").dimmed());
        match executor.execute_query(query_sql).await {
            Ok(batches) => {
                print_query_results(&batches, format)?;
            }
            Err(e) => {
                println!("{} {}", "Query error:".red(), e);
                std::process::exit(1);
            }
        }
        return Ok(());
    }

    // Print results
    let is_machine = format == "json" || format == "csv";

    if is_machine {
        print_results_machine(&exec_result, &manifest, format, duration)?;
    } else {
        println!();
        for result in &exec_result.results {
            let status_colored = match result.status {
                NodeStatus::Success => "OK".green(),
                NodeStatus::Error => "ERROR".red(),
                NodeStatus::Skipped => "SKIP".yellow(),
            };

            let materialization = manifest
                .nodes
                .get(&result.unique_id)
                .and_then(|n| n.materialization())
                .map(|m| format!(" ({m})"))
                .unwrap_or_default();

            let rows = result
                .rows_affected
                .map(|r| format!(" [{r} rows]"))
                .unwrap_or_default();

            let msg = result
                .message
                .as_deref()
                .map(|m| format!(" - {m}"))
                .unwrap_or_default();

            println!(
                "  {} {}{}{}{} [{:.2}s]",
                status_colored,
                result.name.bold(),
                materialization.dimmed(),
                rows,
                msg.dimmed(),
                result.duration.as_secs_f64()
            );
        }

        println!();
        println!(
            "{}",
            format!(
                "Done. {} succeeded, {} errored, {} skipped in {:.2}s",
                exec_result.success_count(),
                exec_result.error_count(),
                exec_result.skipped_count(),
                duration.as_secs_f64()
            )
            .bold()
        );
    }

    // Write run_results.json
    write_run_results(project_dir, &load_state.project, &exec_result, duration)?;

    // Write manifest.json
    write_manifest(project_dir, &load_state.project, &manifest)?;

    // Write compiled SQL files
    write_compiled_sql(project_dir, &load_state.project, &manifest)?;

    if exec_result.error_count() > 0 {
        std::process::exit(1);
    }

    Ok(())
}

fn print_query_results(
    batches: &[datafusion::arrow::record_batch::RecordBatch],
    format: &str,
) -> anyhow::Result<()> {
    if batches.is_empty() {
        println!("(no results)");
        return Ok(());
    }

    match format {
        "json" => {
            let mut rows = Vec::new();
            for batch in batches {
                let schema = batch.schema();
                for row_idx in 0..batch.num_rows() {
                    let mut row = serde_json::Map::new();
                    for col_idx in 0..batch.num_columns() {
                        let col_name = schema.field(col_idx).name().clone();
                        let array = batch.column(col_idx);
                        let value = arrow_value_to_json(array, row_idx);
                        row.insert(col_name, value);
                    }
                    rows.push(serde_json::Value::Object(row));
                }
            }
            println!("{}", serde_json::to_string_pretty(&rows)?);
        }
        "csv" => {
            if let Some(first_batch) = batches.first() {
                let schema = first_batch.schema();
                let headers: Vec<&str> = schema.fields().iter().map(|f| f.name().as_str()).collect();
                println!("{}", headers.join(","));
            }
            for batch in batches {
                for row_idx in 0..batch.num_rows() {
                    let mut cols = Vec::new();
                    for col_idx in 0..batch.num_columns() {
                        let array = batch.column(col_idx);
                        let value = arrow_value_to_string(array, row_idx);
                        cols.push(value);
                    }
                    println!("{}", cols.join(","));
                }
            }
        }
        _ => {
            // Table format using DataFusion's built-in pretty printing
            let formatted = datafusion::arrow::util::pretty::pretty_format_batches(batches)?;
            println!("{formatted}");
        }
    }

    Ok(())
}

fn arrow_value_to_json(
    array: &dyn datafusion::arrow::array::Array,
    row: usize,
) -> serde_json::Value {
    use datafusion::arrow::array::*;
    use datafusion::arrow::datatypes::DataType;

    if array.is_null(row) {
        return serde_json::Value::Null;
    }

    match array.data_type() {
        DataType::Int8 => serde_json::json!(array.as_any().downcast_ref::<Int8Array>().unwrap().value(row)),
        DataType::Int16 => serde_json::json!(array.as_any().downcast_ref::<Int16Array>().unwrap().value(row)),
        DataType::Int32 => serde_json::json!(array.as_any().downcast_ref::<Int32Array>().unwrap().value(row)),
        DataType::Int64 => serde_json::json!(array.as_any().downcast_ref::<Int64Array>().unwrap().value(row)),
        DataType::UInt8 => serde_json::json!(array.as_any().downcast_ref::<UInt8Array>().unwrap().value(row)),
        DataType::UInt16 => serde_json::json!(array.as_any().downcast_ref::<UInt16Array>().unwrap().value(row)),
        DataType::UInt32 => serde_json::json!(array.as_any().downcast_ref::<UInt32Array>().unwrap().value(row)),
        DataType::UInt64 => serde_json::json!(array.as_any().downcast_ref::<UInt64Array>().unwrap().value(row)),
        DataType::Float32 => serde_json::json!(array.as_any().downcast_ref::<Float32Array>().unwrap().value(row)),
        DataType::Float64 => serde_json::json!(array.as_any().downcast_ref::<Float64Array>().unwrap().value(row)),
        DataType::Boolean => serde_json::json!(array.as_any().downcast_ref::<BooleanArray>().unwrap().value(row)),
        DataType::Utf8 => serde_json::json!(array.as_any().downcast_ref::<StringArray>().unwrap().value(row)),
        _ => serde_json::json!(arrow_value_to_string(array, row)),
    }
}

fn arrow_value_to_string(
    array: &dyn datafusion::arrow::array::Array,
    row: usize,
) -> String {
    use datafusion::arrow::array::*;
    use datafusion::arrow::datatypes::DataType;

    if array.is_null(row) {
        return String::new();
    }

    match array.data_type() {
        DataType::Utf8 => array.as_any().downcast_ref::<StringArray>().unwrap().value(row).to_string(),
        DataType::Int64 => array.as_any().downcast_ref::<Int64Array>().unwrap().value(row).to_string(),
        DataType::Int32 => array.as_any().downcast_ref::<Int32Array>().unwrap().value(row).to_string(),
        DataType::Float64 => array.as_any().downcast_ref::<Float64Array>().unwrap().value(row).to_string(),
        DataType::Boolean => array.as_any().downcast_ref::<BooleanArray>().unwrap().value(row).to_string(),
        _ => format!("{:?}", array.as_any()),
    }
}

fn print_results_machine(
    exec_result: &airform_executor::ExecutionResult,
    _manifest: &airform_core::Manifest,
    format: &str,
    duration: std::time::Duration,
) -> anyhow::Result<()> {
    match format {
        "json" => {
            let results: Vec<serde_json::Value> = exec_result
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
            let output = serde_json::json!({
                "results": results,
                "elapsed_secs": duration.as_secs_f64(),
                "success_count": exec_result.success_count(),
                "error_count": exec_result.error_count(),
                "skipped_count": exec_result.skipped_count(),
            });
            println!("{}", serde_json::to_string_pretty(&output)?);
        }
        "csv" => {
            println!("unique_id,name,status,duration_secs,rows_affected,message");
            for r in &exec_result.results {
                println!(
                    "{},{},{},{:.4},{},{}",
                    r.unique_id,
                    r.name,
                    r.status,
                    r.duration.as_secs_f64(),
                    r.rows_affected.map(|v| v.to_string()).unwrap_or_default(),
                    r.message.as_deref().unwrap_or(""),
                );
            }
        }
        _ => {}
    }
    Ok(())
}

fn write_run_results(
    project_dir: &Path,
    project: &airform_core::DbtProject,
    exec_result: &airform_executor::ExecutionResult,
    total_duration: std::time::Duration,
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

fn write_manifest(
    project_dir: &Path,
    project: &airform_core::DbtProject,
    manifest: &airform_core::Manifest,
) -> anyhow::Result<()> {
    let target_dir = project_dir.join(&project.target_path);
    std::fs::create_dir_all(&target_dir)?;

    let path = target_dir.join("manifest.json");
    std::fs::write(&path, serde_json::to_string_pretty(manifest)?)?;
    tracing::info!("Wrote {}", path.display());

    Ok(())
}

fn write_compiled_sql(
    project_dir: &Path,
    project: &airform_core::DbtProject,
    manifest: &airform_core::Manifest,
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
