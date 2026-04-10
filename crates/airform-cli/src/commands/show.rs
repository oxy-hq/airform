use airform_executor::Executor;
use colored::Colorize;
use std::path::Path;

pub async fn run(
    project_dir: &Path,
    select: &str,
    limit: usize,
    target_override: Option<&str>,
) -> anyhow::Result<()> {
    println!("{}", format!("Previewing: {select}").cyan());

    // Load
    let load_state = airform_loader::load_with_target(project_dir, target_override)?;

    // Build context
    let mut ctx = airform_jinja::DbtContext::new(&load_state.project.name);
    if let Some(target) = &load_state.target {
        ctx.target_schema = target.schema.clone().unwrap_or_else(|| "public".to_string());
        ctx.target_database = target.database.clone().unwrap_or_else(|| "main".to_string());
        ctx.target_type = target.adapter_type.clone();
    }

    // Parse
    let mut engine = airform_jinja::JinjaEngine::new();
    let macro_defs: Vec<(String, Vec<String>, String)> = load_state
        .macro_definitions
        .iter()
        .map(|m| (m.name.clone(), m.args.clone(), m.body.clone()))
        .collect();
    engine.load_macros(&macro_defs);

    let mut manifest = airform_parser::parse(&load_state, &engine)?;
    let graph = airform_graph::build_graph(&manifest)?;

    // Compile
    let compiler = airform_compiler::Compiler::new(engine);
    compiler.compile(&mut manifest, &graph, &ctx)?;

    // Execute seeds + models
    let executor = Executor::new();
    executor.load_seeds(&manifest).await?;
    executor.execute(&manifest, &graph, None).await?;

    // Query the selected model
    let query = format!("SELECT * FROM {select} LIMIT {limit}");
    match executor.execute_query(&query).await {
        Ok(batches) => {
            let formatted =
                datafusion::arrow::util::pretty::pretty_format_batches(&batches)?;
            println!("{formatted}");
        }
        Err(e) => {
            println!("{} {}", "Error:".red(), e);
            std::process::exit(1);
        }
    }

    Ok(())
}
