use airform_core::{ColumnDef, DbtProject, Manifest, ResourceType, SourceDefinition, TestDef};
use airform_loader::schema::SchemaFile;

/// Parse source definitions from schema.yml files into the manifest.
pub fn parse_sources(
    project: &DbtProject,
    schema_files: &[SchemaFile],
    manifest: &mut Manifest,
) -> anyhow::Result<()> {
    let mut count = 0;

    for sf in schema_files {
        for source in &sf.contents.sources {
            for table in &source.tables {
                let unique_id = format!(
                    "source.{}.{}.{}",
                    project.name, source.name, table.name
                );

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
                    schema: source.schema.clone(),
                    identifier: table.identifier.clone(),
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
