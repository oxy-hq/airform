use airform_executor::{NodeStatus, TestStatus};
use airform_graph::selector::parse_selection;
use airform_graph::NodeSelector;
use colored::Colorize;
use std::collections::HashSet;
use std::path::Path;
use std::time::Instant;

use super::common;

pub async fn run(project_dir: &Path, select: Option<&str>, target_override: Option<&str>) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Running tests...".cyan());

    let output = common::load_and_compile(project_dir, target_override, false)?;
    let manifest = output.manifest;
    let graph = output.graph;

    // Determine selection
    let selected = if let Some(select) = select {
        let criteria = parse_selection(select);
        let selector = NodeSelector::new(&manifest, &graph);
        Some(selector.select(&criteria))
    } else {
        None
    };

    // Build a set of selected model names for filtering tests
    let selected_model_names: Option<HashSet<String>> = selected.as_ref().map(|ids| {
        ids.iter()
            .filter_map(|id| {
                if let Some(airform_core::ManifestNode::Model(m)) = manifest.nodes.get(id) {
                    Some(m.name.clone())
                } else {
                    None
                }
            })
            .collect()
    });

    // Execute - first load seeds, then run models, then run tests
    let executor = common::create_executor(&output.load_state, &output.target_schema)?;

    // Load seeds
    let seed_results = executor.load_seeds(&manifest).await?;
    for sr in &seed_results {
        if sr.status == NodeStatus::Error {
            tracing::warn!("Seed '{}' failed to load: {:?}", sr.name, sr.message);
        }
    }

    // Execute models so the tables exist for tests
    let exec_result = executor.execute(&manifest, &graph, selected.as_deref()).await?;

    if exec_result.error_count() > 0 {
        println!(
            "{}",
            format!(
                "Warning: {} models had errors during execution",
                exec_result.error_count()
            )
            .yellow()
        );
    }

    // Run tests (filter by selection if provided)
    let all_test_results = executor.execute_tests(&manifest).await?;
    let test_results: Vec<_> = if let Some(ref names) = selected_model_names {
        all_test_results
            .into_iter()
            .filter(|r| names.contains(&r.model_name))
            .collect()
    } else {
        all_test_results
    };
    let duration = start.elapsed();

    // Print results
    println!();
    let mut pass_count = 0;
    let mut fail_count = 0;
    let mut error_count = 0;

    for result in &test_results {
        let status_colored = match result.status {
            TestStatus::Pass => {
                pass_count += 1;
                "PASS".green()
            }
            TestStatus::Fail => {
                fail_count += 1;
                "FAIL".red()
            }
            TestStatus::Error => {
                error_count += 1;
                "ERROR".red()
            }
        };

        let failures_info = if result.failures > 0 {
            format!(" ({} failures)", result.failures)
        } else {
            String::new()
        };

        let msg = result
            .message
            .as_deref()
            .map(|m| format!(" - {m}"))
            .unwrap_or_default();

        println!(
            "  {} {}{}{} [{:.2}s]",
            status_colored,
            result.test_name.bold(),
            failures_info,
            msg.dimmed(),
            result.duration.as_secs_f64()
        );
    }

    println!();
    println!(
        "{}",
        format!(
            "Done. {} passed, {} failed, {} errors in {:.2}s",
            pass_count, fail_count, error_count,
            duration.as_secs_f64()
        )
        .bold()
    );

    if fail_count > 0 || error_count > 0 {
        std::process::exit(1);
    }

    Ok(())
}
