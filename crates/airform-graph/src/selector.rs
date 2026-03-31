use airform_core::{Manifest, ManifestNode, ResourceType, UniqueId};
use crate::dag::DbtGraph;

/// Criteria for selecting nodes, compatible with dbt's selection syntax.
#[derive(Debug, Clone)]
pub enum SelectionCriteria {
    /// Select a specific model by name
    ModelName(String),
    /// Select by path prefix (path:models/staging)
    Path(String),
    /// Select by tag (tag:nightly)
    Tag(String),
    /// Select by resource type
    ResourceType(ResourceType),
    /// Select all ancestors (+model)
    Ancestors(Box<SelectionCriteria>),
    /// Select all descendants (model+)
    Descendants(Box<SelectionCriteria>),
    /// Union of selections
    Union(Vec<SelectionCriteria>),
    /// Intersection of selections
    Intersection(Vec<SelectionCriteria>),
    /// Select all
    All,
}

/// Node selector that filters the manifest based on selection criteria.
pub struct NodeSelector<'a> {
    manifest: &'a Manifest,
    graph: &'a DbtGraph,
}

impl<'a> NodeSelector<'a> {
    pub fn new(manifest: &'a Manifest, graph: &'a DbtGraph) -> Self {
        Self { manifest, graph }
    }

    /// Select nodes matching the criteria
    pub fn select(&self, criteria: &SelectionCriteria) -> Vec<UniqueId> {
        match criteria {
            SelectionCriteria::All => self.manifest.nodes.keys().cloned().collect(),

            SelectionCriteria::ModelName(name) => self
                .manifest
                .nodes
                .iter()
                .filter(|(_, n)| n.name() == name)
                .map(|(id, _)| id.clone())
                .collect(),

            SelectionCriteria::Path(path) => self
                .manifest
                .nodes
                .iter()
                .filter(|(_, n)| {
                    if let ManifestNode::Model(m) = n {
                        m.path.to_string_lossy().starts_with(path.as_str())
                    } else {
                        false
                    }
                })
                .map(|(id, _)| id.clone())
                .collect(),

            SelectionCriteria::Tag(tag) => self
                .manifest
                .nodes
                .iter()
                .filter(|(_, n)| match n {
                    ManifestNode::Model(m) => m.tags.contains(tag) || m.config.tags.contains(tag),
                    _ => false,
                })
                .map(|(id, _)| id.clone())
                .collect(),

            SelectionCriteria::ResourceType(rt) => self
                .manifest
                .nodes
                .iter()
                .filter(|(_, n)| n.resource_type() == rt)
                .map(|(id, _)| id.clone())
                .collect(),

            SelectionCriteria::Ancestors(inner) => {
                let selected = self.select(inner);
                let mut result: Vec<UniqueId> = selected.clone();
                for id in &selected {
                    result.extend(self.graph.ancestors(id));
                }
                result.sort();
                result.dedup();
                result
            }

            SelectionCriteria::Descendants(inner) => {
                let selected = self.select(inner);
                let mut result: Vec<UniqueId> = selected.clone();
                for id in &selected {
                    result.extend(self.graph.descendants(id));
                }
                result.sort();
                result.dedup();
                result
            }

            SelectionCriteria::Union(criteria_list) => {
                let mut result: Vec<UniqueId> = Vec::new();
                for c in criteria_list {
                    result.extend(self.select(c));
                }
                result.sort();
                result.dedup();
                result
            }

            SelectionCriteria::Intersection(criteria_list) => {
                let mut sets: Vec<std::collections::HashSet<UniqueId>> = criteria_list
                    .iter()
                    .map(|c| self.select(c).into_iter().collect())
                    .collect();
                if sets.is_empty() {
                    return Vec::new();
                }
                let first = sets.remove(0);
                first
                    .into_iter()
                    .filter(|id| sets.iter().all(|s| s.contains(id)))
                    .collect()
            }
        }
    }
}

/// Parse a dbt selection string into SelectionCriteria.
/// Supports: model_name, +model_name, model_name+, path:dir, tag:value
pub fn parse_selection(select: &str) -> SelectionCriteria {
    let parts: Vec<&str> = select.split_whitespace().collect();
    if parts.len() > 1 {
        return SelectionCriteria::Union(parts.iter().map(|p| parse_single_selector(p)).collect());
    }
    if parts.is_empty() {
        return SelectionCriteria::All;
    }
    parse_single_selector(parts[0])
}

fn parse_single_selector(s: &str) -> SelectionCriteria {
    // Check for ancestor/descendant operators
    if s.starts_with('+') {
        let inner = parse_single_selector(&s[1..]);
        return SelectionCriteria::Ancestors(Box::new(inner));
    }
    if s.ends_with('+') {
        let inner = parse_single_selector(&s[..s.len() - 1]);
        return SelectionCriteria::Descendants(Box::new(inner));
    }

    // Check for method:value syntax
    if let Some((method, value)) = s.split_once(':') {
        return match method {
            "path" => SelectionCriteria::Path(value.to_string()),
            "tag" => SelectionCriteria::Tag(value.to_string()),
            "resource_type" => {
                match value {
                    "model" => SelectionCriteria::ResourceType(ResourceType::Model),
                    "seed" => SelectionCriteria::ResourceType(ResourceType::Seed),
                    "test" => SelectionCriteria::ResourceType(ResourceType::Test),
                    "snapshot" => SelectionCriteria::ResourceType(ResourceType::Snapshot),
                    "source" => SelectionCriteria::ResourceType(ResourceType::Source),
                    _ => SelectionCriteria::ModelName(s.to_string()),
                }
            }
            _ => SelectionCriteria::ModelName(s.to_string()),
        };
    }

    // Plain model name
    SelectionCriteria::ModelName(s.to_string())
}
