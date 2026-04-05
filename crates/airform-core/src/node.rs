use crate::config::{Materialization, NodeConfig};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;

/// Unique identifier for a node in the DAG
pub type UniqueId = String;

/// Resource type enum matching dbt's NodeType
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ResourceType {
    Model,
    Seed,
    Test,
    Snapshot,
    Source,
    Analysis,
    Macro,
    Exposure,
}

impl std::fmt::Display for ResourceType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ResourceType::Model => write!(f, "model"),
            ResourceType::Seed => write!(f, "seed"),
            ResourceType::Test => write!(f, "test"),
            ResourceType::Snapshot => write!(f, "snapshot"),
            ResourceType::Source => write!(f, "source"),
            ResourceType::Analysis => write!(f, "analysis"),
            ResourceType::Macro => write!(f, "macro"),
            ResourceType::Exposure => write!(f, "exposure"),
        }
    }
}

/// A ref() call found in a model
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct RefCall {
    pub model_name: String,
    /// Optional package/project name (for cross-project refs)
    pub package: Option<String>,
    /// Optional version
    pub version: Option<String>,
}

/// A source() call found in a model
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct SourceCall {
    pub source_name: String,
    pub table_name: String,
}

/// Dependencies extracted from a node's SQL
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct DependsOn {
    pub refs: Vec<RefCall>,
    pub sources: Vec<SourceCall>,
    pub macros: Vec<String>,
}

/// Column definition from schema.yml
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColumnDef {
    pub name: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub data_type: Option<String>,
    #[serde(default)]
    pub tests: Vec<TestDef>,
    #[serde(default)]
    pub meta: HashMap<String, serde_yaml::Value>,
}

/// Test definition from schema.yml
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum TestDef {
    Simple(String),
    Complex(HashMap<String, serde_yaml::Value>),
}

/// A model node in the DAG
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelNode {
    pub unique_id: UniqueId,
    pub name: String,
    pub package_name: String,
    pub resource_type: ResourceType,
    pub path: PathBuf,
    pub original_file_path: PathBuf,

    /// Raw SQL from the file (before Jinja rendering)
    pub raw_sql: String,
    /// Compiled SQL (after Jinja rendering, ref/source resolution)
    pub compiled_sql: Option<String>,
    /// For incremental models: compiled SQL with is_incremental()=false (full refresh variant)
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub compiled_sql_full_refresh: Option<String>,

    pub config: NodeConfig,
    pub depends_on: DependsOn,

    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub columns: Vec<ColumnDef>,
    #[serde(default)]
    pub tags: Vec<String>,

    /// CTEs injected from ephemeral models
    pub extra_ctes: Vec<InjectedCte>,
}

/// A CTE injected from an ephemeral dependency
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InjectedCte {
    pub id: UniqueId,
    pub sql: String,
}

/// A source definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SourceDefinition {
    pub unique_id: UniqueId,
    pub name: String,
    pub source_name: String,
    pub package_name: String,
    pub resource_type: ResourceType,

    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub database: Option<String>,
    #[serde(default)]
    pub schema: Option<String>,
    /// Actual table identifier (defaults to name)
    #[serde(default)]
    pub identifier: Option<String>,
    #[serde(default)]
    pub columns: Vec<ColumnDef>,
    #[serde(default)]
    pub tags: Vec<String>,
    #[serde(default)]
    pub meta: HashMap<String, serde_yaml::Value>,
}

impl SourceDefinition {
    /// The resolved table name (identifier or name)
    pub fn table_identifier(&self) -> &str {
        self.identifier.as_deref().unwrap_or(&self.name)
    }

    /// Fully qualified reference for this source: schema.table
    pub fn relation_name(&self) -> String {
        let schema = self.schema.as_deref().unwrap_or("public");
        let table = self.table_identifier();
        format!("{schema}.{table}")
    }
}

/// A seed node (CSV data)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SeedNode {
    pub unique_id: UniqueId,
    pub name: String,
    pub package_name: String,
    pub resource_type: ResourceType,
    pub path: PathBuf,
    pub config: NodeConfig,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub columns: Vec<ColumnDef>,
}

/// A test node (generic or singular)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TestNode {
    pub unique_id: UniqueId,
    pub name: String,
    pub package_name: String,
    pub resource_type: ResourceType,

    /// Raw SQL for the test
    pub raw_sql: String,
    pub compiled_sql: Option<String>,

    pub depends_on: DependsOn,
    pub config: NodeConfig,

    /// For generic tests, which column/model this tests
    pub test_metadata: Option<TestMetadata>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TestMetadata {
    pub name: String,
    pub kwargs: HashMap<String, serde_yaml::Value>,
}

/// A snapshot node
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SnapshotNode {
    pub unique_id: UniqueId,
    pub name: String,
    pub package_name: String,
    pub resource_type: ResourceType,
    pub path: PathBuf,

    pub raw_sql: String,
    pub compiled_sql: Option<String>,

    pub config: NodeConfig,
    pub depends_on: DependsOn,
}

/// Union type for all nodes that can appear in the DAG
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ManifestNode {
    Model(ModelNode),
    Seed(SeedNode),
    Test(TestNode),
    Snapshot(SnapshotNode),
    Source(SourceDefinition),
}

impl ManifestNode {
    pub fn unique_id(&self) -> &str {
        match self {
            ManifestNode::Model(n) => &n.unique_id,
            ManifestNode::Seed(n) => &n.unique_id,
            ManifestNode::Test(n) => &n.unique_id,
            ManifestNode::Snapshot(n) => &n.unique_id,
            ManifestNode::Source(n) => &n.unique_id,
        }
    }

    pub fn name(&self) -> &str {
        match self {
            ManifestNode::Model(n) => &n.name,
            ManifestNode::Seed(n) => &n.name,
            ManifestNode::Test(n) => &n.name,
            ManifestNode::Snapshot(n) => &n.name,
            ManifestNode::Source(n) => &n.name,
        }
    }

    pub fn resource_type(&self) -> &ResourceType {
        match self {
            ManifestNode::Model(n) => &n.resource_type,
            ManifestNode::Seed(n) => &n.resource_type,
            ManifestNode::Test(n) => &n.resource_type,
            ManifestNode::Snapshot(n) => &n.resource_type,
            ManifestNode::Source(n) => &n.resource_type,
        }
    }

    pub fn materialization(&self) -> Option<&Materialization> {
        match self {
            ManifestNode::Model(n) => Some(&n.config.materialized),
            _ => None,
        }
    }

    pub fn as_model(&self) -> Option<&ModelNode> {
        match self {
            ManifestNode::Model(n) => Some(n),
            _ => None,
        }
    }

    pub fn as_model_mut(&mut self) -> Option<&mut ModelNode> {
        match self {
            ManifestNode::Model(n) => Some(n),
            _ => None,
        }
    }
}
