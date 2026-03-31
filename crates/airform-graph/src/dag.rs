use airform_core::{AirformError, Manifest, ManifestNode, UniqueId};
use petgraph::algo::toposort;
use petgraph::graph::{DiGraph, NodeIndex};
use std::collections::HashMap;

/// The dependency graph for all nodes in the manifest.
#[derive(Debug)]
pub struct DbtGraph {
    graph: DiGraph<UniqueId, ()>,
    node_indices: HashMap<UniqueId, NodeIndex>,
    index_to_id: HashMap<NodeIndex, UniqueId>,
}

impl DbtGraph {
    pub fn new() -> Self {
        Self {
            graph: DiGraph::new(),
            node_indices: HashMap::new(),
            index_to_id: HashMap::new(),
        }
    }

    /// Get a topologically sorted list of node unique_ids.
    /// Nodes are ordered so that dependencies come before dependents.
    pub fn topological_sort(&self) -> Result<Vec<UniqueId>, AirformError> {
        match toposort(&self.graph, None) {
            Ok(indices) => Ok(indices
                .into_iter()
                .filter_map(|idx| self.index_to_id.get(&idx).cloned())
                .collect()),
            Err(cycle) => {
                let cycle_node = self
                    .index_to_id
                    .get(&cycle.node_id())
                    .cloned()
                    .unwrap_or_else(|| "unknown".to_string());
                Err(AirformError::CircularDependency(cycle_node))
            }
        }
    }

    /// Get all ancestors (upstream dependencies) of a node
    pub fn ancestors(&self, node_id: &str) -> Vec<UniqueId> {
        let Some(&idx) = self.node_indices.get(node_id) else {
            return Vec::new();
        };

        let mut visited = std::collections::HashSet::new();
        let mut stack = vec![idx];
        let mut result = Vec::new();

        while let Some(current) = stack.pop() {
            for neighbor in self
                .graph
                .neighbors_directed(current, petgraph::Direction::Incoming)
            {
                if visited.insert(neighbor) {
                    if let Some(id) = self.index_to_id.get(&neighbor) {
                        result.push(id.clone());
                    }
                    stack.push(neighbor);
                }
            }
        }

        result
    }

    /// Get all descendants (downstream dependents) of a node
    pub fn descendants(&self, node_id: &str) -> Vec<UniqueId> {
        let Some(&idx) = self.node_indices.get(node_id) else {
            return Vec::new();
        };

        let mut visited = std::collections::HashSet::new();
        let mut stack = vec![idx];
        let mut result = Vec::new();

        while let Some(current) = stack.pop() {
            for neighbor in self
                .graph
                .neighbors_directed(current, petgraph::Direction::Outgoing)
            {
                if visited.insert(neighbor) {
                    if let Some(id) = self.index_to_id.get(&neighbor) {
                        result.push(id.clone());
                    }
                    stack.push(neighbor);
                }
            }
        }

        result
    }

    /// Get direct parents of a node
    pub fn parents(&self, node_id: &str) -> Vec<UniqueId> {
        let Some(&idx) = self.node_indices.get(node_id) else {
            return Vec::new();
        };

        self.graph
            .neighbors_directed(idx, petgraph::Direction::Incoming)
            .filter_map(|n| self.index_to_id.get(&n).cloned())
            .collect()
    }

    /// Get direct children of a node
    pub fn children(&self, node_id: &str) -> Vec<UniqueId> {
        let Some(&idx) = self.node_indices.get(node_id) else {
            return Vec::new();
        };

        self.graph
            .neighbors_directed(idx, petgraph::Direction::Outgoing)
            .filter_map(|n| self.index_to_id.get(&n).cloned())
            .collect()
    }

    /// Number of nodes in the graph
    pub fn node_count(&self) -> usize {
        self.graph.node_count()
    }

    /// Number of edges in the graph
    pub fn edge_count(&self) -> usize {
        self.graph.edge_count()
    }
}

impl Default for DbtGraph {
    fn default() -> Self {
        Self::new()
    }
}

/// Build the dependency graph from a manifest.
pub fn build_graph(manifest: &Manifest) -> Result<DbtGraph, AirformError> {
    let mut graph = DbtGraph::new();

    // Add all nodes
    for (id, _node) in &manifest.nodes {
        let idx = graph.graph.add_node(id.clone());
        graph.node_indices.insert(id.clone(), idx);
        graph.index_to_id.insert(idx, id.clone());
    }

    // Also add sources as nodes (they can be depended upon)
    for (id, _source) in &manifest.sources {
        let idx = graph.graph.add_node(id.clone());
        graph.node_indices.insert(id.clone(), idx);
        graph.index_to_id.insert(idx, id.clone());
    }

    // Add edges based on depends_on
    for (id, node) in &manifest.nodes {
        let depends_on = match node {
            ManifestNode::Model(m) => Some(&m.depends_on),
            ManifestNode::Test(t) => Some(&t.depends_on),
            ManifestNode::Snapshot(s) => Some(&s.depends_on),
            _ => None,
        };

        if let Some(deps) = depends_on {
            // Resolve ref edges
            for ref_call in &deps.refs {
                if let Some(target) = manifest.resolve_ref(&ref_call.model_name, ref_call.package.as_deref()) {
                    let target_id = target.unique_id().to_string();
                    if let (Some(&from_idx), Some(&to_idx)) =
                        (graph.node_indices.get(&target_id), graph.node_indices.get(id))
                    {
                        graph.graph.add_edge(from_idx, to_idx, ());
                    }
                }
            }

            // Resolve source edges
            for source_call in &deps.sources {
                let source_id_pattern = format!(
                    "source.{}.{}",
                    source_call.source_name, source_call.table_name
                );
                // Find matching source
                for (source_id, _) in &manifest.sources {
                    if source_id.ends_with(&source_id_pattern)
                        || source_id == &source_id_pattern
                    {
                        if let (Some(&from_idx), Some(&to_idx)) =
                            (graph.node_indices.get(source_id), graph.node_indices.get(id))
                        {
                            graph.graph.add_edge(from_idx, to_idx, ());
                        }
                    }
                }
            }
        }
    }

    // Populate parent/child maps on the manifest would happen here
    // but we return the graph for now

    tracing::info!(
        "Built graph with {} nodes and {} edges",
        graph.node_count(),
        graph.edge_count()
    );

    Ok(graph)
}
