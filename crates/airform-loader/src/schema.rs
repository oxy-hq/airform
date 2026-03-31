use airform_core::DbtProject;
use serde::Deserialize;
use std::collections::HashMap;
use std::path::PathBuf;
use walkdir::WalkDir;

/// A parsed schema YAML file (schema.yml / _schema.yml / etc.)
#[derive(Debug, Clone)]
pub struct SchemaFile {
    pub path: PathBuf,
    pub contents: SchemaFileContents,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SchemaFileContents {
    #[serde(default)]
    pub version: Option<i32>,

    #[serde(default)]
    pub models: Vec<SchemaModel>,

    #[serde(default)]
    pub sources: Vec<SchemaSource>,

    #[serde(default)]
    pub seeds: Vec<SchemaSeed>,

    #[serde(default)]
    pub snapshots: Vec<SchemaSnapshot>,

    #[serde(default)]
    pub exposures: Vec<serde_yaml::Value>,

    #[serde(default)]
    pub metrics: Vec<serde_yaml::Value>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SchemaModel {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub columns: Vec<SchemaColumn>,
    #[serde(default)]
    pub config: Option<HashMap<String, serde_yaml::Value>>,
    #[serde(default)]
    pub tests: Vec<serde_yaml::Value>,
    #[serde(default)]
    pub meta: HashMap<String, serde_yaml::Value>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SchemaSource {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub database: Option<String>,
    #[serde(default)]
    pub schema: Option<String>,
    #[serde(default)]
    pub tables: Vec<SchemaSourceTable>,
    #[serde(default)]
    pub meta: HashMap<String, serde_yaml::Value>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SchemaSourceTable {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub identifier: Option<String>,
    #[serde(default)]
    pub columns: Vec<SchemaColumn>,
    #[serde(default)]
    pub meta: HashMap<String, serde_yaml::Value>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SchemaColumn {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub data_type: Option<String>,
    #[serde(default)]
    pub tests: Vec<serde_yaml::Value>,
    #[serde(default)]
    pub meta: HashMap<String, serde_yaml::Value>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SchemaSeed {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub columns: Vec<SchemaColumn>,
    #[serde(default)]
    pub config: Option<HashMap<String, serde_yaml::Value>>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct SchemaSnapshot {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub columns: Vec<SchemaColumn>,
}

/// Discover and parse all YAML schema files in the project
pub fn load_schema_files(project: &DbtProject) -> anyhow::Result<Vec<SchemaFile>> {
    let mut files = Vec::new();

    // Look in model paths, seed paths, snapshot paths, and test paths
    let search_paths: Vec<&str> = project
        .model_paths
        .iter()
        .chain(project.seed_paths.iter())
        .chain(project.snapshot_paths.iter())
        .chain(project.test_paths.iter())
        .map(|s| s.as_str())
        .collect();

    for dir_name in search_paths {
        let dir = project.project_root.join(dir_name);
        if !dir.exists() {
            continue;
        }

        for entry in WalkDir::new(&dir)
            .follow_links(true)
            .into_iter()
            .filter_map(|e| e.ok())
        {
            let path = entry.path();
            if path.extension().is_some_and(|ext| ext == "yml" || ext == "yaml") {
                match std::fs::read_to_string(path) {
                    Ok(contents) => match serde_yaml::from_str::<SchemaFileContents>(&contents) {
                        Ok(parsed) => {
                            files.push(SchemaFile {
                                path: path.to_path_buf(),
                                contents: parsed,
                            });
                        }
                        Err(e) => {
                            tracing::debug!(
                                "Skipping non-schema YAML {}: {}",
                                path.display(),
                                e
                            );
                        }
                    },
                    Err(e) => {
                        tracing::warn!("Could not read {}: {}", path.display(), e);
                    }
                }
            }
        }
    }

    tracing::info!("Loaded {} schema files", files.len());
    Ok(files)
}
