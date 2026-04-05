use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;

/// Environment configuration for dev/staging/prod
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Environment {
    pub name: String,
    #[serde(default)]
    pub target: Option<String>,
    #[serde(default)]
    pub schema_prefix: Option<String>,
    #[serde(default)]
    pub schema_suffix: Option<String>,
}

/// Represents a parsed dbt_project.yml
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DbtProject {
    pub name: String,

    #[serde(default = "default_config_version")]
    pub config_version: i32,
    // In dbt-core, config-version is a top-level key that's important for parsing.
    // We treat config-version: 2 as default (the only supported version now).

    #[serde(default)]
    pub version: Option<String>,

    #[serde(default)]
    pub profile: Option<String>,

    #[serde(default = "default_model_paths", alias = "model-paths")]
    pub model_paths: Vec<String>,

    #[serde(default = "default_seed_paths", alias = "seed-paths")]
    pub seed_paths: Vec<String>,

    #[serde(default = "default_test_paths", alias = "test-paths")]
    pub test_paths: Vec<String>,

    #[serde(default = "default_macro_paths", alias = "macro-paths")]
    pub macro_paths: Vec<String>,

    #[serde(default = "default_snapshot_paths", alias = "snapshot-paths")]
    pub snapshot_paths: Vec<String>,

    #[serde(default = "default_analysis_paths", alias = "analysis-paths")]
    pub analysis_paths: Vec<String>,

    #[serde(default = "default_target_path", alias = "target-path")]
    pub target_path: String,

    #[serde(default = "default_clean_targets", alias = "clean-targets")]
    pub clean_targets: Vec<String>,

    /// Model-level config overrides keyed by project name -> path -> config
    #[serde(default)]
    pub models: Option<serde_yaml::Value>,

    /// Seed-level config overrides
    #[serde(default)]
    pub seeds: Option<serde_yaml::Value>,

    /// Snapshot-level config overrides
    #[serde(default)]
    pub snapshots: Option<serde_yaml::Value>,

    /// Test-level config overrides
    #[serde(default)]
    pub tests: Option<serde_yaml::Value>,

    /// Variables
    #[serde(default)]
    pub vars: HashMap<String, serde_yaml::Value>,

    /// Project-level dispatch config
    #[serde(default)]
    pub dispatch: Vec<DispatchConfig>,

    /// Environment configurations (dev, staging, prod)
    #[serde(default)]
    pub environments: Vec<Environment>,

    /// dbt_project.yml location on disk
    #[serde(skip)]
    pub project_root: PathBuf,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DispatchConfig {
    pub macro_namespace: String,
    pub search_order: Vec<String>,
}

/// Represents profiles.yml
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DbtProfiles {
    #[serde(flatten)]
    pub profiles: HashMap<String, DbtProfile>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DbtProfile {
    pub target: String,
    pub outputs: HashMap<String, DbtTarget>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DbtTarget {
    #[serde(rename = "type")]
    pub adapter_type: String,

    #[serde(default)]
    pub schema: Option<String>,

    #[serde(default)]
    pub database: Option<String>,

    #[serde(default)]
    pub threads: Option<usize>,

    /// All other adapter-specific fields
    #[serde(flatten)]
    pub extra: HashMap<String, serde_yaml::Value>,
}

/// Materialization strategy for a model
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Materialization {
    View,
    Table,
    Incremental,
    Ephemeral,
}

impl Default for Materialization {
    fn default() -> Self {
        Self::View
    }
}

impl std::fmt::Display for Materialization {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Materialization::View => write!(f, "view"),
            Materialization::Table => write!(f, "table"),
            Materialization::Incremental => write!(f, "incremental"),
            Materialization::Ephemeral => write!(f, "ephemeral"),
        }
    }
}

impl std::str::FromStr for Materialization {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_lowercase().as_str() {
            "view" => Ok(Self::View),
            "table" => Ok(Self::Table),
            "incremental" => Ok(Self::Incremental),
            "ephemeral" => Ok(Self::Ephemeral),
            other => Err(format!("Unknown materialization: {other}")),
        }
    }
}

/// Contract enforcement configuration for a model.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ContractConfig {
    #[serde(default)]
    pub enforced: bool,
}

/// Node-level configuration (from config() macro or dbt_project.yml)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NodeConfig {
    #[serde(default)]
    pub materialized: Materialization,

    #[serde(default)]
    pub schema: Option<String>,

    #[serde(default)]
    pub database: Option<String>,

    #[serde(default)]
    pub alias: Option<String>,

    #[serde(default)]
    pub tags: Vec<String>,

    #[serde(default)]
    pub meta: HashMap<String, serde_yaml::Value>,

    #[serde(default)]
    pub enabled: Option<bool>,

    #[serde(default)]
    pub unique_key: Option<String>,

    #[serde(default)]
    pub incremental_strategy: Option<String>,

    #[serde(default)]
    pub on_schema_change: Option<String>,

    #[serde(default)]
    pub contract: Option<ContractConfig>,

    /// Snapshot strategy: "timestamp" or "check"
    #[serde(default)]
    pub strategy: Option<String>,

    /// Column to check for changes (timestamp strategy)
    #[serde(default)]
    pub updated_at: Option<String>,

    /// Columns to check for changes (check strategy)
    #[serde(default)]
    pub check_cols: Option<Vec<String>>,

    /// Any extra config keys
    #[serde(flatten)]
    pub extra: HashMap<String, serde_yaml::Value>,
}

impl Default for NodeConfig {
    fn default() -> Self {
        Self {
            materialized: Materialization::View,
            schema: None,
            database: None,
            alias: None,
            tags: Vec::new(),
            meta: HashMap::new(),
            enabled: None,
            unique_key: None,
            incremental_strategy: None,
            on_schema_change: None,
            contract: None,
            strategy: None,
            updated_at: None,
            check_cols: None,
            extra: HashMap::new(),
        }
    }
}

// Defaults for dbt_project.yml fields
fn default_config_version() -> i32 {
    2
}
fn default_model_paths() -> Vec<String> {
    vec!["models".to_string()]
}
fn default_seed_paths() -> Vec<String> {
    vec!["seeds".to_string()]
}
fn default_test_paths() -> Vec<String> {
    vec!["tests".to_string()]
}
fn default_macro_paths() -> Vec<String> {
    vec!["macros".to_string()]
}
fn default_snapshot_paths() -> Vec<String> {
    vec!["snapshots".to_string()]
}
fn default_analysis_paths() -> Vec<String> {
    vec!["analyses".to_string()]
}
fn default_target_path() -> String {
    "target".to_string()
}
fn default_clean_targets() -> Vec<String> {
    vec!["target".to_string(), "dbt_packages".to_string()]
}
