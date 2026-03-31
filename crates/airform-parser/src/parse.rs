use airform_core::{
    ColumnDef, DbtProject, DependsOn, Manifest, ManifestNode, Materialization, ModelNode,
    NodeConfig, ResourceType, TestDef,
};
use airform_jinja::{DbtContext, JinjaEngine};
use airform_loader::discover::ModelFile;
use airform_loader::schema::{SchemaFile, SchemaModel};
use std::collections::HashMap;

/// Parse all model SQL files into ModelNodes and add them to the manifest.
pub fn parse_models(
    project: &DbtProject,
    model_files: &[ModelFile],
    schema_files: &[SchemaFile],
    engine: &JinjaEngine,
    manifest: &mut Manifest,
) -> anyhow::Result<()> {
    for model_file in model_files {
        let raw_sql = std::fs::read_to_string(&model_file.path)?;
        let unique_id = format!("model.{}.{}", project.name, model_file.name);

        // First pass: render with execute=false to extract refs/sources/config
        let ctx = DbtContext::new(&project.name);
        let _ = engine.render(&raw_sql, &ctx);

        let refs = ctx.take_refs();
        let sources = ctx.take_sources();
        let config_from_sql = ctx.take_config();

        // Build node config: merge dbt_project.yml config -> schema.yml config -> SQL config()
        let mut config = resolve_model_config(project, model_file, schema_files);

        // Apply config() from SQL (highest priority)
        if let Some(mat) = config_from_sql.get("materialized") {
            if let Ok(m) = mat.parse::<Materialization>() {
                config.materialized = m;
            }
        }
        if let Some(schema) = config_from_sql.get("schema") {
            config.schema = Some(schema.clone());
        }
        if let Some(alias) = config_from_sql.get("alias") {
            config.alias = Some(alias.clone());
        }
        if let Some(tags) = config_from_sql.get("tags") {
            config.tags = tags.split(',').map(|s| s.trim().to_string()).collect();
        }
        if let Some(uk) = config_from_sql.get("unique_key") {
            config.unique_key = Some(uk.clone());
        }

        // Find schema.yml metadata for this model
        let schema_model = find_schema_model(schema_files, &model_file.name);
        let (description, columns) = if let Some(sm) = schema_model {
            (
                sm.description.clone(),
                sm.columns
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
                    .collect(),
            )
        } else {
            (None, Vec::new())
        };

        let depends_on = DependsOn {
            refs,
            sources,
            macros: Vec::new(),
        };

        let node = ModelNode {
            unique_id: unique_id.clone(),
            name: model_file.name.clone(),
            package_name: project.name.clone(),
            resource_type: ResourceType::Model,
            path: model_file.relative_path.clone(),
            original_file_path: model_file.path.clone(),
            raw_sql,
            compiled_sql: None,
            config,
            depends_on,
            description,
            columns,
            tags: Vec::new(),
            extra_ctes: Vec::new(),
        };

        manifest.add_node(ManifestNode::Model(node));
    }

    tracing::info!("Parsed {} models", model_files.len());
    Ok(())
}

/// Resolve model config from dbt_project.yml hierarchy
fn resolve_model_config(
    project: &DbtProject,
    model_file: &ModelFile,
    schema_files: &[SchemaFile],
) -> NodeConfig {
    let mut config = NodeConfig::default();

    // Check dbt_project.yml models config
    if let Some(models_config) = &project.models {
        if let Some(project_models) = models_config.as_mapping() {
            // Look for project-level config under project name
            let key = serde_yaml::Value::String(project.name.clone());
            if let Some(project_config) = project_models.get(&key) {
                apply_yaml_config(&mut config, project_config);

                // Walk the path hierarchy
                if let Some(mapping) = project_config.as_mapping() {
                    let path_parts: Vec<String> = model_file
                        .relative_path
                        .parent()
                        .map(|p: &std::path::Path| {
                            p.components()
                                .filter_map(|c: std::path::Component| {
                                    c.as_os_str().to_str().map(String::from)
                                })
                                .collect()
                        })
                        .unwrap_or_default();

                    let mut current = mapping.clone();
                    for part in &path_parts {
                        let sub_key = serde_yaml::Value::String(part.to_string());
                        if let Some(sub) = current.get(&sub_key) {
                            apply_yaml_config(&mut config, sub);
                            if let Some(sub_map) = sub.as_mapping() {
                                current = sub_map.clone();
                            } else {
                                break;
                            }
                        } else {
                            break;
                        }
                    }
                }
            }
        }
    }

    // Check schema.yml config for this model
    if let Some(sm) = find_schema_model(schema_files, &model_file.name) {
        if let Some(ref schema_config) = sm.config {
            let schema_cfg: &HashMap<String, serde_yaml::Value> = schema_config;
            if let Some(serde_yaml::Value::String(mat_str)) = schema_cfg.get("materialized") {
                if let Ok(m) = mat_str.parse::<Materialization>() {
                    config.materialized = m;
                }
            }
            if let Some(serde_yaml::Value::String(schema_str)) = schema_cfg.get("schema") {
                config.schema = Some(schema_str.clone());
            }
        }
    }

    config
}

fn apply_yaml_config(config: &mut NodeConfig, value: &serde_yaml::Value) {
    if let Some(mapping) = value.as_mapping() {
        // Look for +materialized or materialized
        for key_prefix in ["", "+"] {
            let mat_key = serde_yaml::Value::String(format!("{key_prefix}materialized"));
            if let Some(mat) = mapping.get(&mat_key) {
                if let Some(s) = mat.as_str() {
                    if let Ok(m) = s.parse::<Materialization>() {
                        config.materialized = m;
                    }
                }
            }

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

            let enabled_key = serde_yaml::Value::String(format!("{key_prefix}enabled"));
            if let Some(enabled) = mapping.get(&enabled_key) {
                if let Some(b) = enabled.as_bool() {
                    config.enabled = Some(b);
                }
            }
        }
    }
}

fn find_schema_model<'a>(
    schema_files: &'a [SchemaFile],
    model_name: &str,
) -> Option<&'a SchemaModel> {
    for sf in schema_files {
        for m in &sf.contents.models {
            if m.name == model_name {
                return Some(m);
            }
        }
    }
    None
}
