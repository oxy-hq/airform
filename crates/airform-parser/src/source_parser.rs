use airform_core::{ColumnDef, DbtProject, Manifest, ResourceType, SourceDefinition, TestDef};
use airform_jinja::{DbtContext, JinjaEngine};
use airform_loader::schema::SchemaFile;

/// Render a string through the Jinja engine if it contains Jinja expressions.
/// This is used to resolve `{{ var('X', 'default') }}` in source YAML fields.
fn render_jinja_field(
    value: Option<&str>,
    engine: &JinjaEngine,
    ctx: &DbtContext,
) -> Option<String> {
    let val = value?;
    if val.contains("{{") || val.contains("{%") {
        match engine.render(val, ctx) {
            Ok(rendered) => {
                let trimmed = rendered.trim().to_string();
                if trimmed.is_empty() { None } else { Some(trimmed) }
            }
            Err(_) => Some(val.to_string()),
        }
    } else {
        Some(val.to_string())
    }
}

/// Parse source definitions from schema.yml files into the manifest.
/// Jinja expressions in `schema` and `identifier` fields are rendered
/// using the provided engine (resolves `var()` calls, etc.).
pub fn parse_sources(
    project: &DbtProject,
    schema_files: &[SchemaFile],
    engine: &JinjaEngine,
    manifest: &mut Manifest,
) -> anyhow::Result<()> {
    let mut count = 0;

    // Build a Jinja context with project vars so var() calls resolve
    let mut ctx = DbtContext::new(&project.name);
    ctx.populate_vars(&project.vars);
    ctx.execute = false;
    tracing::debug!("Source parser vars: {} entries", ctx.vars.len());
    tracing::debug!("Schema files: {}, total sources: {}", schema_files.len(),
        schema_files.iter().map(|sf| sf.contents.sources.len()).sum::<usize>());

    for sf in schema_files {
        for source in &sf.contents.sources {
            tracing::debug!("Processing source '{}' with {} tables", source.name, source.tables.len());
            // Render schema at the source level (applies to all tables)
            let resolved_schema = render_jinja_field(
                source.schema.as_deref(),
                engine,
                &ctx,
            );

            for table in &source.tables {
                let unique_id = format!(
                    "source.{}.{}.{}",
                    project.name, source.name, table.name
                );

                // Render table identifier through Jinja
                let resolved_identifier = render_jinja_field(
                    table.identifier.as_deref(),
                    engine,
                    &ctx,
                );
                tracing::debug!("Source {}.{}: identifier raw={:?} resolved={:?}",
                    source.name, table.name, table.identifier, resolved_identifier);

                let columns: Vec<ColumnDef> = table
                    .columns
                    .iter()
                    .map(|c| {
                        let tests: Vec<TestDef> = c
                            .tests
                            .iter()
                            .map(|t: &serde_yaml::Value| {
                                if let Some(s) = t.as_str() {
                                    TestDef::Simple(s.to_string())
                                } else {
                                    TestDef::Simple(format!("{t:?}"))
                                }
                            })
                            .collect();
                        ColumnDef {
                            name: c.name.clone(),
                            description: c.description.clone(),
                            data_type: c.data_type.clone(),
                            tests,
                            meta: c.meta.clone(),
                        }
                    })
                    .collect();

                let source_def = SourceDefinition {
                    unique_id,
                    name: table.name.clone(),
                    source_name: source.name.clone(),
                    package_name: project.name.clone(),
                    resource_type: ResourceType::Source,
                    description: table
                        .description
                        .clone()
                        .or_else(|| source.description.clone()),
                    database: source.database.clone(),
                    schema: resolved_schema.clone(),
                    identifier: resolved_identifier,
                    columns,
                    tags: Vec::new(),
                    meta: table.meta.clone(),
                };

                manifest.add_source(source_def);
                count += 1;
            }
        }
    }

    tracing::info!("Parsed {count} source tables");
    Ok(())
}
