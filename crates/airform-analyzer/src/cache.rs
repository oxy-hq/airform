use datafusion::arrow::datatypes::{DataType, Field, SchemaRef, TimeUnit};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::sync::Arc;

/// Cache for analysis results, enabling incremental re-analysis.
///
/// Stores per-model compiled SQL hashes and their inferred schemas.
/// On subsequent runs, models whose compiled SQL hash hasn't changed
/// (and whose upstream schemas are unchanged) can skip re-analysis.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct AnalysisCache {
    /// Map of model name -> cached analysis entry
    pub entries: HashMap<String, CacheEntry>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CacheEntry {
    /// Hash of the compiled SQL that produced this schema
    pub sql_hash: String,
    /// Hashes of upstream model schemas (model_name -> schema_hash)
    pub upstream_hashes: HashMap<String, String>,
    /// Serialized schema fields
    pub schema: Vec<CachedField>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CachedField {
    pub name: String,
    pub data_type: String,
    pub nullable: bool,
}

impl AnalysisCache {
    /// Load cache from the target directory.
    pub fn load(target_dir: &Path) -> Self {
        let path = Self::cache_path(target_dir);
        if path.exists() {
            match std::fs::read_to_string(&path) {
                Ok(contents) => match serde_json::from_str(&contents) {
                    Ok(cache) => return cache,
                    Err(e) => {
                        tracing::debug!("Could not parse analysis cache: {e}");
                    }
                },
                Err(e) => {
                    tracing::debug!("Could not read analysis cache: {e}");
                }
            }
        }
        Self::default()
    }

    /// Save cache to the target directory.
    pub fn save(&self, target_dir: &Path) -> anyhow::Result<()> {
        std::fs::create_dir_all(target_dir)?;
        let path = Self::cache_path(target_dir);
        let json = serde_json::to_string_pretty(self)?;
        std::fs::write(&path, json)?;
        Ok(())
    }

    /// Check if a model can be skipped (compiled SQL unchanged, upstream schemas unchanged).
    pub fn is_fresh(
        &self,
        model_name: &str,
        compiled_sql: &str,
        upstream_schemas: &HashMap<String, SchemaRef>,
    ) -> bool {
        let Some(entry) = self.entries.get(model_name) else {
            return false;
        };

        // Check compiled SQL hash
        let current_hash = hash_string(compiled_sql);
        if entry.sql_hash != current_hash {
            return false;
        }

        // Check upstream schema hashes
        for (upstream_name, upstream_hash) in &entry.upstream_hashes {
            match upstream_schemas.get(upstream_name) {
                Some(schema) => {
                    if hash_schema(schema) != *upstream_hash {
                        return false;
                    }
                }
                None => return false, // upstream schema disappeared
            }
        }

        true
    }

    /// Store analysis results for a model.
    pub fn update(
        &mut self,
        model_name: &str,
        compiled_sql: &str,
        schema: &SchemaRef,
        upstream_schemas: &HashMap<String, SchemaRef>,
    ) {
        let cached_fields: Vec<CachedField> = schema
            .fields()
            .iter()
            .map(|f| CachedField {
                name: f.name().clone(),
                data_type: format!("{}", f.data_type()),
                nullable: f.is_nullable(),
            })
            .collect();

        let upstream_hashes: HashMap<String, String> = upstream_schemas
            .iter()
            .map(|(name, schema)| (name.clone(), hash_schema(schema)))
            .collect();

        self.entries.insert(
            model_name.to_string(),
            CacheEntry {
                sql_hash: hash_string(compiled_sql),
                upstream_hashes,
                schema: cached_fields,
            },
        );
    }

    /// Restore a cached schema to an Arrow SchemaRef.
    pub fn restore_schema(&self, model_name: &str) -> Option<SchemaRef> {
        let entry = self.entries.get(model_name)?;
        let fields: Vec<Field> = entry
            .schema
            .iter()
            .map(|f| Field::new(&f.name, parse_cached_type(&f.data_type), f.nullable))
            .collect();
        Some(Arc::new(datafusion::arrow::datatypes::Schema::new(fields)))
    }

    fn cache_path(target_dir: &Path) -> PathBuf {
        target_dir.join(".airform_analysis_cache.json")
    }
}

fn hash_string(s: &str) -> String {
    use std::collections::hash_map::DefaultHasher;
    use std::hash::{Hash, Hasher};
    let mut hasher = DefaultHasher::new();
    s.hash(&mut hasher);
    format!("{:016x}", hasher.finish())
}

fn hash_schema(schema: &SchemaRef) -> String {
    let repr: String = schema
        .fields()
        .iter()
        .map(|f| format!("{}:{}", f.name(), f.data_type()))
        .collect::<Vec<_>>()
        .join(",");
    hash_string(&repr)
}

/// Parse a cached type string back to DataType.
fn parse_cached_type(type_str: &str) -> DataType {
    match type_str {
        "Int32" => DataType::Int32,
        "Int64" => DataType::Int64,
        "Float32" => DataType::Float32,
        "Float64" => DataType::Float64,
        "Utf8" => DataType::Utf8,
        "Boolean" => DataType::Boolean,
        "Date32" => DataType::Date32,
        "Timestamp(Nanosecond, None)" => DataType::Timestamp(TimeUnit::Nanosecond, None),
        _ => DataType::Utf8,
    }
}
