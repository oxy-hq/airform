use serde::{Deserialize, Serialize};
use std::path::Path;

/// A catalog file providing source schemas for analysis.
///
/// When sources don't have matching seeds or schema.yml column types,
/// the catalog provides the missing schema information. This is the
/// typical case in production where seed CSVs aren't available.
///
/// Format (catalog.yml):
/// ```yaml
/// version: 1
/// sources:
///   - name: raw
///     tables:
///       - name: users
///         columns:
///           - name: id
///             type: integer
///           - name: email
///             type: varchar
/// ```
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Catalog {
    #[serde(default)]
    pub sources: Vec<CatalogSource>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CatalogSource {
    pub name: String,
    #[serde(default)]
    pub tables: Vec<CatalogTable>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CatalogTable {
    pub name: String,
    #[serde(default)]
    pub columns: Vec<CatalogColumn>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CatalogColumn {
    pub name: String,
    #[serde(rename = "type")]
    pub data_type: String,
}

impl Catalog {
    /// Load a catalog from a YAML file. Returns an empty catalog if the file doesn't exist.
    pub fn load(project_dir: &Path) -> Self {
        let catalog_path = project_dir.join("catalog.yml");
        if !catalog_path.exists() {
            // Also check catalog.yaml
            let alt_path = project_dir.join("catalog.yaml");
            if !alt_path.exists() {
                return Self::default();
            }
            return Self::load_from_path(&alt_path);
        }
        Self::load_from_path(&catalog_path)
    }

    fn load_from_path(path: &Path) -> Self {
        match std::fs::read_to_string(path) {
            Ok(contents) => match serde_yaml::from_str(&contents) {
                Ok(catalog) => {
                    tracing::debug!("Loaded catalog from {}", path.display());
                    catalog
                }
                Err(e) => {
                    tracing::warn!("Failed to parse catalog {}: {e}", path.display());
                    Self::default()
                }
            },
            Err(e) => {
                tracing::warn!("Failed to read catalog {}: {e}", path.display());
                Self::default()
            }
        }
    }

    /// Look up column definitions for a source table.
    /// Matches by source_name and table_name.
    pub fn lookup(&self, source_name: &str, table_name: &str) -> Option<&[CatalogColumn]> {
        for source in &self.sources {
            if source.name == source_name {
                for table in &source.tables {
                    if table.name == table_name {
                        return Some(&table.columns);
                    }
                }
            }
        }
        None
    }

    pub fn is_empty(&self) -> bool {
        self.sources.is_empty()
    }
}
