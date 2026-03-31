//! Tests for graph operations: topological sort, ancestors/descendants, selectors.

use std::path::PathBuf;

use airform_graph::{build_graph, selector, DbtGraph, NodeSelector, SelectionCriteria};
use airform_jinja::JinjaEngine;
use airform_loader;
use airform_parser;

fn jaffle_shop_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("examples/jaffle-shop")
}

fn build_jaffle_manifest_and_graph() -> (airform_core::Manifest, DbtGraph) {
    let load_state = airform_loader::load(&jaffle_shop_dir()).unwrap();
    let engine = JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine).unwrap();
    let graph = build_graph(&manifest).unwrap();
    (manifest, graph)
}

// ---------------------------------------------------------------------------
// Topological sort
// ---------------------------------------------------------------------------

#[test]
fn test_topological_sort_no_cycles() {
    let (_manifest, graph) = build_jaffle_manifest_and_graph();
    let order = graph.topological_sort();
    assert!(order.is_ok(), "topological sort should succeed (no cycles)");
}

#[test]
fn test_topological_sort_dependencies_before_dependents() {
    let (_manifest, graph) = build_jaffle_manifest_and_graph();
    let order = graph.topological_sort().unwrap();

    // For every edge A -> B in the graph, A should appear before B.
    // We'll check a few known relationships:
    // stg_orders should come before orders (mart)
    let find_pos = |substring: &str| -> Option<usize> {
        order.iter().position(|id| id.contains(substring))
    };

    // Seeds/sources should come before staging models
    if let (Some(stg_orders), Some(orders)) = (
        find_pos("stg_orders"),
        find_pos("model.jaffle_shop.orders"),
    ) {
        assert!(
            stg_orders < orders,
            "stg_orders (pos {stg_orders}) should precede orders (pos {orders})"
        );
    }

    // stg_payments should come before orders (mart)
    if let (Some(stg_payments), Some(orders)) = (
        find_pos("stg_payments"),
        find_pos("model.jaffle_shop.orders"),
    ) {
        assert!(
            stg_payments < orders,
            "stg_payments (pos {stg_payments}) should precede orders (pos {orders})"
        );
    }
}

// ---------------------------------------------------------------------------
// Ancestors / Descendants
// ---------------------------------------------------------------------------

#[test]
fn test_ancestors_of_customers_model() {
    let (manifest, graph) = build_jaffle_manifest_and_graph();

    // Find the customers model unique_id
    let customers_id = manifest
        .nodes
        .iter()
        .find(|(_, n)| n.name() == "customers" && matches!(n, airform_core::ManifestNode::Model(_)))
        .map(|(id, _)| id.clone())
        .expect("customers model not found");

    let ancestors = graph.ancestors(&customers_id);

    // customers depends on stg_customers, stg_orders, stg_payments
    // which in turn depend on sources/seeds
    assert!(
        ancestors.len() >= 3,
        "customers should have at least 3 ancestors, got: {:?}",
        ancestors
    );

    // Check that at least one staging model is an ancestor
    let has_staging_ancestor = ancestors.iter().any(|a| a.contains("stg_"));
    assert!(has_staging_ancestor, "customers should have staging ancestors");
}

#[test]
fn test_descendants_of_stg_orders() {
    let (manifest, graph) = build_jaffle_manifest_and_graph();

    let stg_orders_id = manifest
        .nodes
        .iter()
        .find(|(_, n)| n.name() == "stg_orders" && matches!(n, airform_core::ManifestNode::Model(_)))
        .map(|(id, _)| id.clone())
        .expect("stg_orders model not found");

    let descendants = graph.descendants(&stg_orders_id);

    // stg_orders should have customers and orders as descendants
    let has_customers = descendants.iter().any(|d| d.contains("customers"));
    let has_orders = descendants.iter().any(|d| d.contains(".orders"));
    assert!(has_customers, "stg_orders should have customers as descendant");
    assert!(has_orders, "stg_orders should have orders as descendant");
}

#[test]
fn test_ancestors_of_leaf_node_is_empty() {
    let (_manifest, graph) = build_jaffle_manifest_and_graph();
    // A source node should have no ancestors
    let ancestors = graph.ancestors("nonexistent_node_xyz");
    assert!(ancestors.is_empty(), "nonexistent node should have no ancestors");
}

#[test]
fn test_parents_and_children() {
    let (manifest, graph) = build_jaffle_manifest_and_graph();

    let orders_id = manifest
        .nodes
        .iter()
        .find(|(_, n)| n.name() == "orders" && matches!(n, airform_core::ManifestNode::Model(_)))
        .map(|(id, _)| id.clone())
        .expect("orders model not found");

    let parents = graph.parents(&orders_id);
    // orders depends on stg_orders and stg_payments
    assert!(
        parents.len() >= 2,
        "orders should have at least 2 direct parents, got: {:?}",
        parents
    );

    // orders (mart) should have no children in jaffle-shop
    let children = graph.children(&orders_id);
    assert!(
        children.is_empty(),
        "orders (mart) should have no children, got: {:?}",
        children
    );
}

// ---------------------------------------------------------------------------
// Node selection parsing
// ---------------------------------------------------------------------------

#[test]
fn test_parse_model_name_selection() {
    let criteria = selector::parse_selection("stg_customers");
    match criteria {
        SelectionCriteria::ModelName(name) => assert_eq!(name, "stg_customers"),
        other => panic!("expected ModelName, got: {:?}", other),
    }
}

#[test]
fn test_parse_ancestors_selection() {
    let criteria = selector::parse_selection("+customers");
    match criteria {
        SelectionCriteria::Ancestors(inner) => match *inner {
            SelectionCriteria::ModelName(name) => assert_eq!(name, "customers"),
            other => panic!("expected ModelName inside Ancestors, got: {:?}", other),
        },
        other => panic!("expected Ancestors, got: {:?}", other),
    }
}

#[test]
fn test_parse_descendants_selection() {
    let criteria = selector::parse_selection("stg_orders+");
    match criteria {
        SelectionCriteria::Descendants(inner) => match *inner {
            SelectionCriteria::ModelName(name) => assert_eq!(name, "stg_orders"),
            other => panic!("expected ModelName inside Descendants, got: {:?}", other),
        },
        other => panic!("expected Descendants, got: {:?}", other),
    }
}

#[test]
fn test_parse_path_selection() {
    let criteria = selector::parse_selection("path:models/staging");
    match criteria {
        SelectionCriteria::Path(path) => assert_eq!(path, "models/staging"),
        other => panic!("expected Path, got: {:?}", other),
    }
}

#[test]
fn test_parse_tag_selection() {
    let criteria = selector::parse_selection("tag:nightly");
    match criteria {
        SelectionCriteria::Tag(tag) => assert_eq!(tag, "nightly"),
        other => panic!("expected Tag, got: {:?}", other),
    }
}

#[test]
fn test_parse_union_selection() {
    let criteria = selector::parse_selection("stg_customers stg_orders");
    match criteria {
        SelectionCriteria::Union(items) => {
            assert_eq!(items.len(), 2);
        }
        other => panic!("expected Union, got: {:?}", other),
    }
}

// ---------------------------------------------------------------------------
// Node selection execution
// ---------------------------------------------------------------------------

#[test]
fn test_select_by_model_name() {
    let (manifest, graph) = build_jaffle_manifest_and_graph();
    let selector = NodeSelector::new(&manifest, &graph);

    let criteria = selector::parse_selection("customers");
    let selected = selector.select(&criteria);

    assert_eq!(selected.len(), 1, "should select exactly 1 node for 'customers'");
    assert!(selected[0].contains("customers"));
}

#[test]
fn test_select_ancestors() {
    let (manifest, graph) = build_jaffle_manifest_and_graph();
    let selector = NodeSelector::new(&manifest, &graph);

    let criteria = selector::parse_selection("+customers");
    let selected = selector.select(&criteria);

    // +customers = customers + all upstream deps (stg_customers, stg_orders, stg_payments, seeds, sources)
    assert!(
        selected.len() >= 4,
        "selecting +customers should give at least 4 nodes, got {}",
        selected.len()
    );
}

#[test]
fn test_select_descendants() {
    let (manifest, graph) = build_jaffle_manifest_and_graph();
    let selector = NodeSelector::new(&manifest, &graph);

    let criteria = selector::parse_selection("stg_orders+");
    let selected = selector.select(&criteria);

    // stg_orders+ = stg_orders + customers + orders (at least)
    assert!(
        selected.len() >= 3,
        "selecting stg_orders+ should give at least 3 nodes, got {}",
        selected.len()
    );
}

#[test]
fn test_select_all() {
    let (manifest, graph) = build_jaffle_manifest_and_graph();
    let selector = NodeSelector::new(&manifest, &graph);

    let criteria = SelectionCriteria::All;
    let selected = selector.select(&criteria);

    // All nodes (models + seeds)
    assert_eq!(
        selected.len(),
        manifest.nodes.len(),
        "selecting All should return all manifest nodes"
    );
}
