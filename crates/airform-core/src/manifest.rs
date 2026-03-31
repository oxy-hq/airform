use crate::config::DbtProject;
use crate::node::{ManifestNode, ModelNode, SourceDefinition, UniqueId};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// The manifest is the central data structure containing all parsed nodes.
/// Analogous to dbt's manifest.json / SDF's compiled workspace state.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Manifest {
    pub nodes: HashMap<UniqueId, ManifestNode>,
    pub sources: HashMap<UniqueId, SourceDefinition>,
    pub parent_map: HashMap<UniqueId, Vec<UniqueId>>,
    pub child_map: HashMap<UniqueId, Vec<UniqueId>>,
    pub metadata: ManifestMetadata,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ManifestMetadata {
    pub project_name: Option<String>,
    pub generated_at: Option<String>,
    pub airform_version: Option<String>,
}

impl Manifest {
    pub fn new() -> Self {
        Self::default()
    }

    /// Add a node to the manifest
    pub fn add_node(&mut self, node: ManifestNode) {
        let id = node.unique_id().to_string();
        self.nodes.insert(id, node);
    }

    /// Add a source definition
    pub fn add_source(&mut self, source: SourceDefinition) {
        let id = source.unique_id.clone();
        self.sources.insert(id, source);
    }

    /// Resolve a ref() call to a node unique_id
    pub fn resolve_ref(&self, model_name: &str, package: Option<&str>) -> Option<&ManifestNode> {
        self.nodes.values().find(|node| {
            let name_matches = node.name() == model_name;
            let pkg_matches = package
                .map(|p| match node {
                    ManifestNode::Model(m) => m.package_name == p,
                    ManifestNode::Seed(s) => s.package_name == p,
                    ManifestNode::Snapshot(s) => s.package_name == p,
                    _ => false,
                })
                .unwrap_or(true);

            // Only refable types: Model, Seed, Snapshot
            let is_refable = matches!(
                node,
                ManifestNode::Model(_) | ManifestNode::Seed(_) | ManifestNode::Snapshot(_)
            );

            name_matches && pkg_matches && is_refable
        })
    }

    /// Resolve a source() call
    pub fn resolve_source(
        &self,
        source_name: &str,
        table_name: &str,
    ) -> Option<&SourceDefinition> {
        self.sources.values().find(|s| {
            s.source_name == source_name && (s.name == table_name || s.identifier.as_deref() == Some(table_name))
        })
    }

    /// Get all model nodes
    pub fn models(&self) -> impl Iterator<Item = &ModelNode> {
        self.nodes.values().filter_map(|n| n.as_model())
    }

    /// Populate the manifest metadata from project config
    pub fn set_metadata(&mut self, project: &DbtProject) {
        self.metadata.project_name = Some(project.name.clone());
        self.metadata.airform_version = Some(env!("CARGO_PKG_VERSION").to_string());
        self.metadata.generated_at = Some(chrono::Utc::now().to_rfc3339());
    }
}
