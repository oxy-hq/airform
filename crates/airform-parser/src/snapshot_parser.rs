use airform_core::{
    DbtProject, DependsOn, Manifest, ManifestNode, NodeConfig, ResourceType, SnapshotNode,
};
use airform_jinja::{DbtContext, JinjaEngine};
use airform_loader::discover::SnapshotFile;
use airform_loader::schema::SchemaFile;

/// Parse all snapshot SQL files into SnapshotNodes and add them to the manifest.
pub fn parse_snapshots(
    project: &DbtProject,
    snapshot_files: &[SnapshotFile],
    schema_files: &[SchemaFile],
    engine: &JinjaEngine,
    manifest: &mut Manifest,
) -> anyhow::Result<()> {
    for snapshot_file in snapshot_files {
        let raw_sql = std::fs::read_to_string(&snapshot_file.path)?;
        let unique_id = format!("snapshot.{}.{}", project.name, snapshot_file.name);

        // First pass: render with execute=false to extract refs/sources/config
        let mut ctx = DbtContext::new(&project.name);
        ctx.populate_vars(&project.vars);
        let _ = engine.render(&raw_sql, &ctx);

        let refs = ctx.take_refs();
        let sources = ctx.take_sources();
        let config_from_sql = ctx.take_config();

        // Build node config from schema.yml and SQL config()
        let mut config = resolve_snapshot_config(project, &snapshot_file.name, schema_files);

        // Apply config() from SQL (highest priority)
        if let Some(strategy) = config_from_sql.get("strategy") {
            config.strategy = Some(strategy.clone());
        }
        if let Some(unique_key) = config_from_sql.get("unique_key") {
            config.unique_key = Some(unique_key.clone());
        }
        if let Some(updated_at) = config_from_sql.get("updated_at") {
            config.updated_at = Some(updated_at.clone());
        }
        if let Some(check_cols) = config_from_sql.get("check_cols") {
            config.check_cols = Some(
                check_cols
                    .split(',')
                    .map(|s| s.trim().to_string())
                    .collect(),
            );
        }
        if let Some(schema) = config_from_sql.get("schema") {
            config.schema = Some(schema.clone());
        }
        if let Some(alias) = config_from_sql.get("alias") {
            config.alias = Some(alias.clone());
        }

        let depends_on = DependsOn {
            refs,
            sources,
            macros: Vec::new(),
        };

        let node = SnapshotNode {
            unique_id: unique_id.clone(),
            name: snapshot_file.name.clone(),
            package_name: project.name.clone(),
            resource_type: ResourceType::Snapshot,
            path: snapshot_file.relative_path.clone(),
            raw_sql,
            compiled_sql: None,
            config,
            depends_on,
        };

        manifest.add_node(ManifestNode::Snapshot(node));
    }

    tracing::info!("Parsed {} snapshots", snapshot_files.len());
    Ok(())
}

/// Resolve snapshot config from schema.yml and dbt_project.yml
fn resolve_snapshot_config(
    project: &DbtProject,
    snapshot_name: &str,
    schema_files: &[SchemaFile],
) -> NodeConfig {
    let mut config = NodeConfig::default();

    // Check dbt_project.yml snapshots config
    if let Some(snapshots_config) = &project.snapshots {
        if let Some(project_snapshots) = snapshots_config.as_mapping() {
            let key = serde_yaml::Value::String(project.name.clone());
            if let Some(project_config) = project_snapshots.get(&key) {
                apply_snapshot_yaml_config(&mut config, project_config);
            }
        }
    }

    // Check schema.yml for snapshot-specific config
    for sf in schema_files {
        for snap in &sf.contents.snapshots {
            if snap.name == snapshot_name {
                // SchemaSnapshot currently only has name/description/columns
                // Future: could add config field like SchemaModel has
                break;
            }
        }
    }

    config
}

fn apply_snapshot_yaml_config(config: &mut NodeConfig, value: &serde_yaml::Value) {
    if let Some(mapping) = value.as_mapping() {
        for key_prefix in ["", "+"] {
            let strategy_key = serde_yaml::Value::String(format!("{key_prefix}strategy"));
            if let Some(v) = mapping.get(&strategy_key) {
                if let Some(s) = v.as_str() {
                    config.strategy = Some(s.to_string());
                }
            }

            let unique_key_key = serde_yaml::Value::String(format!("{key_prefix}unique_key"));
            if let Some(v) = mapping.get(&unique_key_key) {
                if let Some(s) = v.as_str() {
                    config.unique_key = Some(s.to_string());
                }
            }

            let updated_at_key = serde_yaml::Value::String(format!("{key_prefix}updated_at"));
            if let Some(v) = mapping.get(&updated_at_key) {
                if let Some(s) = v.as_str() {
                    config.updated_at = Some(s.to_string());
                }
            }

            let check_cols_key = serde_yaml::Value::String(format!("{key_prefix}check_cols"));
            if let Some(v) = mapping.get(&check_cols_key) {
                if let Some(seq) = v.as_sequence() {
                    config.check_cols = Some(
                        seq.iter()
                            .filter_map(|v| v.as_str().map(String::from))
                            .collect(),
                    );
                }
            }

            let schema_key = serde_yaml::Value::String(format!("{key_prefix}schema"));
            if let Some(v) = mapping.get(&schema_key) {
                if let Some(s) = v.as_str() {
                    config.schema = Some(s.to_string());
                }
            }
        }
    }
}
