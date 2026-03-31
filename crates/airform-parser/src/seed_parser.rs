use airform_core::{
    ColumnDef, DbtProject, Manifest, ManifestNode, NodeConfig, ResourceType, SeedNode, TestDef,
};
use airform_loader::discover::SeedFile;
use airform_loader::schema::SchemaFile;

/// Parse all discovered seed CSV files into SeedNodes and add them to the manifest.
pub fn parse_seeds(
    project: &DbtProject,
    seed_files: &[SeedFile],
    schema_files: &[SchemaFile],
    manifest: &mut Manifest,
) -> anyhow::Result<()> {
    for seed_file in seed_files {
        let unique_id = format!("seed.{}.{}", project.name, seed_file.name);

        let mut config = NodeConfig::default();
        config.materialized = airform_core::Materialization::Table;

        // Check dbt_project.yml seeds config for schema override
        if let Some(seeds_config) = &project.seeds {
            if let Some(project_seeds) = seeds_config.as_mapping() {
                let key = serde_yaml::Value::String(project.name.clone());
                if let Some(project_cfg) = project_seeds.get(&key) {
                    apply_seed_yaml_config(&mut config, project_cfg);
                }
            }
        }

        // Find schema.yml metadata for this seed
        let schema_seed = find_schema_seed(schema_files, &seed_file.name);
        let (description, columns) = if let Some(ss) = schema_seed {
            (
                ss.description.clone(),
                ss.columns
                    .iter()
                    .map(|c| {
                        let tests: Vec<TestDef> = c
                            .tests
                            .iter()
                            .map(|t| {
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
                    .collect(),
            )
        } else {
            (None, Vec::new())
        };

        let node = SeedNode {
            unique_id: unique_id.clone(),
            name: seed_file.name.clone(),
            package_name: project.name.clone(),
            resource_type: ResourceType::Seed,
            path: seed_file.path.clone(),
            config,
            description,
            columns,
        };

        manifest.add_node(ManifestNode::Seed(node));
    }

    tracing::info!("Parsed {} seeds", seed_files.len());
    Ok(())
}

fn apply_seed_yaml_config(config: &mut NodeConfig, value: &serde_yaml::Value) {
    if let Some(mapping) = value.as_mapping() {
        for key_prefix in ["", "+"] {
            let schema_key = serde_yaml::Value::String(format!("{key_prefix}schema"));
            if let Some(schema) = mapping.get(&schema_key) {
                if let Some(s) = schema.as_str() {
                    config.schema = Some(s.to_string());
                }
            }

            let tags_key = serde_yaml::Value::String(format!("{key_prefix}tags"));
            if let Some(tags) = mapping.get(&tags_key) {
                if let Some(seq) = tags.as_sequence() {
                    config.tags = seq
                        .iter()
                        .filter_map(|v| v.as_str().map(String::from))
                        .collect();
                }
            }
        }
    }
}

fn find_schema_seed<'a>(
    schema_files: &'a [SchemaFile],
    seed_name: &str,
) -> Option<&'a airform_loader::schema::SchemaSeed> {
    for sf in schema_files {
        for s in &sf.contents.seeds {
            if s.name == seed_name {
                return Some(s);
            }
        }
    }
    None
}
