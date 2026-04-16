use colored::Colorize;
use std::path::Path;
use std::time::Instant;

pub async fn run(
    project_dir: &Path,
    select: Option<&str>,
    target_override: Option<&str>,
    show_lineage: bool,
    column: Option<&str>,
) -> anyhow::Result<()> {
    let start = Instant::now();
    println!("{}", "Analyzing project SQL...".cyan());

    // Load
    let load_state = airform_loader::load_with_target(project_dir, target_override)?;

    // Build Jinja context
    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    ctx.populate_vars(&load_state.project.vars);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }

    // Parse
    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String, Option<String>)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone(), m.package.clone()))
        .collect();
    engine.load_macros_with_packages(&macro_defs);

    let mut manifest = airform_parser::parse(&load_state, &engine)?;

    // Build graph
    let graph = airform_graph::build_graph(&manifest)?;

    // Compile (required for analysis — we need compiled SQL)
    let compiler = airform_compiler::Compiler::new(engine);
    let compile_result = compiler.compile(&mut manifest, &graph, &ctx)?;

    // Load incremental analysis cache
    let target_dir = project_dir.join(&load_state.project.target_path);
    let mut cache = airform_analyzer::AnalysisCache::load(&target_dir);

    // Analyze (with project_dir for catalog.yml and cache for incremental analysis)
    let adapter_type = load_state.target.as_ref().map(|t| t.adapter_type.as_str());
    let analysis = airform_analyzer::Analyzer::analyze(
        &manifest,
        &graph,
        Some(project_dir),
        Some(&mut cache),
        adapter_type,
    )
    .await?;

    // Save updated cache
    if let Err(e) = cache.save(&target_dir) {
        tracing::debug!("Failed to save analysis cache: {e}");
    }

    let duration = start.elapsed();

    // Print schema results
    let schema_count = analysis.schemas.len();
    let diag_count = analysis.diagnostics.len();

    println!();
    println!(
        "{}",
        format!(
            "Analysis complete: {} models compiled, {} schemas resolved, {} diagnostics{}",
            compile_result.compiled_count,
            schema_count,
            diag_count,
            if analysis.cached_count > 0 {
                format!(" ({} from cache)", analysis.cached_count)
            } else {
                String::new()
            }
        )
        .green()
        .bold()
    );
    println!("  Elapsed: {:.2}s", duration.as_secs_f64());

    // Print diagnostics
    if !analysis.diagnostics.is_empty() {
        println!();
        println!("{}", "Diagnostics:".yellow().bold());
        for diag in &analysis.diagnostics {
            match diag {
                airform_analyzer::AnalyzerDiagnostic::SqlError { model, message } => {
                    println!("  {} {}: {}", "ERROR".red(), model, message);
                }
                airform_analyzer::AnalyzerDiagnostic::SchemaUnavailable { node } => {
                    tracing::debug!("Schema unavailable: {node}");
                }
            }
        }
    }

    // Print contract violations
    if !analysis.contract_violations.is_empty() {
        println!();
        println!("{}", "Contract violations:".red().bold());
        for v in &analysis.contract_violations {
            println!("  {} {}", "ERROR".red(), v);
        }
    }

    // Print inferred schemas
    if let Some(model_name) = select {
        if let Some(schema) = analysis.schemas.get(model_name) {
            println!();
            println!("{} {}", "Schema for:".bold(), model_name.cyan());
            println!(
                "  {:30} {:15} {}",
                "COLUMN".bold(),
                "TYPE".bold(),
                "NULLABLE".bold()
            );
            println!("  {}", "-".repeat(55));
            for field in schema.fields() {
                println!(
                    "  {:30} {:15} {}",
                    field.name(),
                    format!("{}", field.data_type()),
                    if field.is_nullable() { "YES" } else { "NO" }
                );
            }
        }

        // Show column-level lineage if requested
        if show_lineage || column.is_some() {
            println!();
            if let Some(col_name) = column {
                println!(
                    "{} {}.{}",
                    "Column lineage for:".bold(),
                    model_name.cyan(),
                    col_name.cyan()
                );

                let trace = analysis.lineage.trace_column(model_name, col_name);
                if trace.is_empty() {
                    println!("  {}", "(no lineage found)".dimmed());
                } else {
                    print_lineage_table(&trace);
                }
            } else {
                println!("{} {}", "Column lineage for:".bold(), model_name.cyan());
                let model_edges: Vec<_> = analysis
                    .lineage
                    .edges
                    .iter()
                    .filter(|e| e.target_node == model_name)
                    .collect();
                if model_edges.is_empty() {
                    println!("  {}", "(no lineage found)".dimmed());
                } else {
                    print_lineage_table(&model_edges);
                }
            }
        }
    } else if show_lineage {
        // Show all lineage edges
        println!();
        println!("{}", "Column-level lineage:".bold());
        let all_edges: Vec<_> = analysis.lineage.edges.iter().collect();
        if all_edges.is_empty() {
            println!("  {}", "(no lineage found)".dimmed());
        } else {
            print_lineage_table(&all_edges);
        }
    }

    if !analysis.contract_violations.is_empty() {
        return Err(anyhow::anyhow!(
            "{} contract violation(s) found",
            analysis.contract_violations.len()
        ));
    }

    Ok(())
}

fn print_lineage_table(edges: &[&airform_analyzer::ColumnLineage]) {
    println!(
        "  {:30} {:20} {:10} {:30} {}",
        "SOURCE NODE".bold(),
        "SOURCE COLUMN".bold(),
        "TYPE".bold(),
        "TARGET NODE".bold(),
        "TARGET COLUMN".bold()
    );
    println!("  {}", "-".repeat(100));
    for edge in edges {
        let dep_type = match edge.dependency_type {
            airform_analyzer::DependencyType::Copy => "copy".green(),
            airform_analyzer::DependencyType::Transform => "transform".yellow(),
            airform_analyzer::DependencyType::Scan => "scan".dimmed(),
        };
        println!(
            "  {:30} {:20} {:10} {:30} {}",
            edge.source_node, edge.source_column, dep_type, edge.target_node, edge.target_column
        );
    }
}
