use airform_executor::{Executor, NodeStatus};
use colored::Colorize;
use std::path::Path;
use std::time::Instant;

use super::common;

pub async fn run(
    project_dir: &Path,
    select: Option<&str>,
    exclude: Option<&str>,
    query: Option<&str>,
    format: &str,
    target_override: Option<&str>,
    full_refresh: bool,
) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Running models...".cyan());

    let output = common::load_and_compile(project_dir, target_override, full_refresh)?;
    let load_state = output.load_state;
    let manifest = output.manifest;
    let graph = output.graph;

    let selected = common::apply_selection(&manifest, &graph, select, exclude);

    // Execute - load seeds first, then models
    let executor = Executor::new();

    // Register information schema tables
    if let Err(e) =
        airform_executor::register_info_schema(executor.session_context(), &manifest, &graph)
    {
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
        common::print_exec_results_machine(&exec_result, None, format, duration)?;
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

    // Write artifacts
    common::write_run_results(project_dir, &load_state.project, &exec_result, duration)?;
    common::write_manifest(project_dir, &load_state.project, &manifest)?;
    common::write_compiled_sql(project_dir, &load_state.project, &manifest)?;

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
                let headers: Vec<&str> =
                    schema.fields().iter().map(|f| f.name().as_str()).collect();
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
