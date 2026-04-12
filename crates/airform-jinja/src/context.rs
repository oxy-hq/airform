use airform_core::{RefCall, SourceCall};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};

/// Captures ref() and source() calls during Jinja rendering.
/// In parse mode (execute=false), these just record dependencies.
/// In execute mode, they resolve to actual relation names.
#[derive(Debug, Clone)]
pub struct DbtContext {
    /// Project name
    pub project_name: String,

    /// Whether we're in execute mode
    pub execute: bool,

    /// Variables from dbt_project.yml vars and --vars CLI flag
    pub vars: HashMap<String, String>,

    /// Target info for {{ target.name }}, {{ target.schema }}, etc.
    pub target_name: String,
    pub target_schema: String,
    pub target_database: String,
    pub target_type: String,

    /// Collected refs (populated during rendering)
    pub refs: Arc<Mutex<Vec<RefCall>>>,

    /// Collected sources (populated during rendering)
    pub sources: Arc<Mutex<Vec<SourceCall>>>,

    /// Config values from config() blocks (populated during rendering)
    pub config_values: Arc<Mutex<HashMap<String, String>>>,

    /// Resolved ref relations (model_name -> "schema.table")
    pub ref_resolutions: HashMap<String, String>,

    /// Resolved source relations ((source_name, table_name) -> "schema.table")
    pub source_resolutions: HashMap<(String, String), String>,

    /// Whether --full-refresh was passed
    pub full_refresh: bool,

    /// Whether this model is being run incrementally (materialization=incremental and not full_refresh)
    pub is_incremental: bool,

    /// The `{{ this }}` relation name for incremental models
    pub this_relation: Option<String>,
}

impl DbtContext {
    pub fn new(project_name: &str) -> Self {
        Self {
            project_name: project_name.to_string(),
            execute: false,
            vars: HashMap::new(),
            target_name: "dev".to_string(),
            target_schema: "public".to_string(),
            target_database: "main".to_string(),
            target_type: "datafusion".to_string(),
            refs: Arc::new(Mutex::new(Vec::new())),
            sources: Arc::new(Mutex::new(Vec::new())),
            config_values: Arc::new(Mutex::new(HashMap::new())),
            ref_resolutions: HashMap::new(),
            source_resolutions: HashMap::new(),
            full_refresh: false,
            is_incremental: false,
            this_relation: None,
        }
    }

    /// Populate vars from dbt_project.yml `vars:` section.
    /// Handles both top-level vars and package-scoped vars (nested under package name).
    /// Converts serde_yaml::Value to String for use in var() calls.
    pub fn populate_vars(&mut self, project_vars: &std::collections::HashMap<String, serde_yaml::Value>) {
        for (key, value) in project_vars {
            match value {
                // Package-scoped vars: { package_name: { var_name: value } }
                serde_yaml::Value::Mapping(map) => {
                    for (k, v) in map {
                        if let serde_yaml::Value::String(var_name) = k {
                            let str_val = match v {
                                serde_yaml::Value::String(s) => s.clone(),
                                serde_yaml::Value::Bool(b) => b.to_string(),
                                serde_yaml::Value::Number(n) => n.to_string(),
                                serde_yaml::Value::Null => continue,
                                other => match serde_yaml::to_string(other) {
                                    Ok(s) => s.trim().to_string(),
                                    Err(_) => continue,
                                },
                            };
                            self.vars.insert(var_name.clone(), str_val);
                        }
                    }
                    // Also store the package key itself if it's a known pattern
                    // (some projects use `var('package_name:key')`)
                }
                serde_yaml::Value::String(s) => {
                    self.vars.insert(key.clone(), s.clone());
                }
                serde_yaml::Value::Bool(b) => {
                    self.vars.insert(key.clone(), b.to_string());
                }
                serde_yaml::Value::Number(n) => {
                    self.vars.insert(key.clone(), n.to_string());
                }
                serde_yaml::Value::Null => continue,
                other => {
                    if let Ok(s) = serde_yaml::to_string(other) {
                        self.vars.insert(key.clone(), s.trim().to_string());
                    }
                }
            }
        }
    }

    pub fn take_refs(&self) -> Vec<RefCall> {
        std::mem::take(&mut *self.refs.lock().unwrap())
    }

    pub fn take_sources(&self) -> Vec<SourceCall> {
        std::mem::take(&mut *self.sources.lock().unwrap())
    }

    pub fn take_config(&self) -> HashMap<String, String> {
        std::mem::take(&mut *self.config_values.lock().unwrap())
    }
}
