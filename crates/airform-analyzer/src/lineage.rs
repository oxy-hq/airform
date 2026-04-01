use datafusion::logical_expr::{Expr, LogicalPlan, Projection};
use serde::{Deserialize, Serialize};
use std::collections::HashSet;

/// Type of column dependency.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum DependencyType {
    /// Direct column pass-through (SELECT col FROM ...)
    Copy,
    /// Column used in an expression (SELECT col + 1 AS x)
    Transform,
    /// Column used in WHERE/JOIN/GROUP BY
    Scan,
}

impl std::fmt::Display for DependencyType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            DependencyType::Copy => write!(f, "copy"),
            DependencyType::Transform => write!(f, "transform"),
            DependencyType::Scan => write!(f, "scan"),
        }
    }
}

/// A single column-level lineage edge.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColumnLineage {
    pub source_node: String,
    pub source_column: String,
    pub target_node: String,
    pub target_column: String,
    pub dependency_type: DependencyType,
}

/// Column lineage graph for an entire project.
#[derive(Debug, Clone, Default)]
pub struct ColumnLineageGraph {
    pub edges: Vec<ColumnLineage>,
}

impl ColumnLineageGraph {
    /// Get all lineage edges for a specific target column.
    pub fn edges_for_column(&self, target_node: &str, target_column: &str) -> Vec<&ColumnLineage> {
        self.edges
            .iter()
            .filter(|e| e.target_node == target_node && e.target_column == target_column)
            .collect()
    }

    /// Trace the full lineage of a column back through the entire DAG.
    pub fn trace_column(&self, target_node: &str, target_column: &str) -> Vec<&ColumnLineage> {
        let mut result = Vec::new();
        let mut stack: Vec<(&str, &str)> = vec![(target_node, target_column)];
        let mut visited = HashSet::new();

        while let Some((node, col)) = stack.pop() {
            if !visited.insert((node.to_string(), col.to_string())) {
                continue;
            }
            let direct = self.edges_for_column(node, col);
            for edge in &direct {
                result.push(*edge);
                stack.push((&edge.source_node, &edge.source_column));
            }
        }

        result
    }
}

/// Extract column-level lineage from a DataFusion logical plan.
///
/// Walks the plan tree to determine which input columns contribute to each
/// output column, and classifies the dependency as Copy, Transform, or Scan.
pub fn extract_lineage_from_plan(plan: &LogicalPlan, model_name: &str) -> Vec<ColumnLineage> {
    let mut edges = Vec::new();

    // Collect all table scans in the plan (leaf nodes)
    let table_names = collect_table_scans(plan);

    // Build alias -> table name mappings (CTE aliases -> underlying table scans)
    let alias_map = build_alias_map(plan);

    // Find the top-level projection (may be wrapped in SubqueryAlias, etc.)
    let projection = find_top_projection(plan);

    if let Some(proj) = projection {
        for (_i, expr) in proj.expr.iter().enumerate() {
            // Get the output column name: use alias if present, otherwise
            // the bare column name (strip any table qualifier)
            let output_col = match expr {
                Expr::Alias(alias) => alias.name.clone(),
                Expr::Column(col) => col.name.clone(),
                _ => expr.schema_name().to_string(),
            };
            let input_cols = extract_column_refs(expr);

            if input_cols.is_empty() {
                continue;
            }

            // Determine dependency type
            let dep_type = if input_cols.len() == 1 && is_simple_column_ref(expr) {
                DependencyType::Copy
            } else {
                DependencyType::Transform
            };

            for (qualifier, col_name) in &input_cols {
                let source_node = resolve_source_table(qualifier.as_deref(), &table_names, &alias_map);
                edges.push(ColumnLineage {
                    source_node,
                    source_column: col_name.clone(),
                    target_node: model_name.to_string(),
                    target_column: output_col.clone(),
                    dependency_type: dep_type.clone(),
                });
            }
        }

        // Also extract scan dependencies from filter/join conditions
        extract_scan_deps(&proj.input, model_name, &table_names, &alias_map, &mut edges);
    } else {
        // Fallback: map output fields to source tables
        let output_schema = plan.schema();
        for field in output_schema.fields() {
            let col_name = field.name().clone();
            for table in &table_names {
                edges.push(ColumnLineage {
                    source_node: table.clone(),
                    source_column: col_name.clone(),
                    target_node: model_name.to_string(),
                    target_column: col_name.clone(),
                    dependency_type: DependencyType::Copy,
                });
            }
        }

        // Extract scan deps from the full plan
        extract_scan_deps(plan, model_name, &table_names, &alias_map, &mut edges);
    }

    edges
}

/// Find the top-level Projection in a plan, unwrapping SubqueryAlias, Sort, Limit, etc.
/// Skips wildcard-only projections (`SELECT *`) to find the real projection underneath.
fn find_top_projection(plan: &LogicalPlan) -> Option<&Projection> {
    match plan {
        LogicalPlan::Projection(proj) => {
            // If projection is just SELECT *, look deeper for the real projection
            #[allow(deprecated)]
            let is_wildcard_only = proj.expr.len() == 1
                && matches!(proj.expr[0], Expr::Wildcard { .. });
            if is_wildcard_only {
                find_top_projection(&proj.input)
            } else {
                Some(proj)
            }
        }
        LogicalPlan::SubqueryAlias(alias) => find_top_projection(&alias.input),
        LogicalPlan::Sort(sort) => find_top_projection(&sort.input),
        LogicalPlan::Limit(limit) => find_top_projection(&limit.input),
        LogicalPlan::Distinct(distinct) => find_top_projection(distinct.input()),
        _ => None,
    }
}

/// Collect all table scan names from a logical plan tree.
fn collect_table_scans(plan: &LogicalPlan) -> Vec<String> {
    let mut tables = Vec::new();
    collect_table_scans_inner(plan, &mut tables);
    tables
}

fn collect_table_scans_inner(plan: &LogicalPlan, tables: &mut Vec<String>) {
    match plan {
        LogicalPlan::TableScan(scan) => {
            let name = scan.table_name.to_string();
            if !tables.contains(&name) {
                tables.push(name);
            }
        }
        LogicalPlan::SubqueryAlias(alias) => {
            // Don't descend into subquery aliases as separate tables —
            // they're CTEs or derived tables, not source tables.
            // But we do want to collect any table scans inside them.
            collect_table_scans_inner(&alias.input, tables);
        }
        _ => {
            for child in plan.inputs() {
                collect_table_scans_inner(child, tables);
            }
        }
    }
}

/// Extract all column references from an expression.
/// Returns (qualifier, column_name) pairs.
fn extract_column_refs(expr: &Expr) -> Vec<(Option<String>, String)> {
    let mut refs = Vec::new();
    extract_column_refs_inner(expr, &mut refs);
    refs
}

fn extract_column_refs_inner(expr: &Expr, refs: &mut Vec<(Option<String>, String)>) {
    match expr {
        Expr::Column(col) => {
            let qualifier = col.relation.as_ref().map(|r| r.to_string());
            refs.push((qualifier, col.name.clone()));
        }
        Expr::Alias(alias) => {
            extract_column_refs_inner(&alias.expr, refs);
        }
        Expr::BinaryExpr(bin) => {
            extract_column_refs_inner(&bin.left, refs);
            extract_column_refs_inner(&bin.right, refs);
        }
        Expr::ScalarFunction(func) => {
            for arg in &func.args {
                extract_column_refs_inner(arg, refs);
            }
        }
        Expr::AggregateFunction(agg) => {
            for arg in &agg.params.args {
                extract_column_refs_inner(arg, refs);
            }
        }
        Expr::Cast(cast) => {
            extract_column_refs_inner(&cast.expr, refs);
        }
        Expr::TryCast(cast) => {
            extract_column_refs_inner(&cast.expr, refs);
        }
        Expr::Case(case) => {
            if let Some(ref operand) = case.expr {
                extract_column_refs_inner(operand, refs);
            }
            for (when_expr, then_expr) in &case.when_then_expr {
                extract_column_refs_inner(when_expr, refs);
                extract_column_refs_inner(then_expr, refs);
            }
            if let Some(ref else_expr) = case.else_expr {
                extract_column_refs_inner(else_expr, refs);
            }
        }
        Expr::IsNull(inner) | Expr::IsNotNull(inner) | Expr::Not(inner) | Expr::Negative(inner) => {
            extract_column_refs_inner(inner, refs);
        }
        Expr::Between(between) => {
            extract_column_refs_inner(&between.expr, refs);
            extract_column_refs_inner(&between.low, refs);
            extract_column_refs_inner(&between.high, refs);
        }
        Expr::Like(like) => {
            extract_column_refs_inner(&like.expr, refs);
            extract_column_refs_inner(&like.pattern, refs);
        }
        Expr::SimilarTo(similar) => {
            extract_column_refs_inner(&similar.expr, refs);
            extract_column_refs_inner(&similar.pattern, refs);
        }
        Expr::InList(in_list) => {
            extract_column_refs_inner(&in_list.expr, refs);
            for item in &in_list.list {
                extract_column_refs_inner(item, refs);
            }
        }
        Expr::WindowFunction(wf) => {
            for arg in &wf.params.args {
                extract_column_refs_inner(arg, refs);
            }
            for part in &wf.params.partition_by {
                extract_column_refs_inner(part, refs);
            }
            for order in &wf.params.order_by {
                extract_column_refs_inner(&order.expr, refs);
            }
        }
        // Literals, wildcards, placeholders — no column refs
        _ => {}
    }
}

/// Check if an expression is a simple column reference (possibly aliased).
fn is_simple_column_ref(expr: &Expr) -> bool {
    match expr {
        Expr::Column(_) => true,
        Expr::Alias(alias) => is_simple_column_ref(&alias.expr),
        _ => false,
    }
}

/// Build a mapping from CTE/subquery alias names to their underlying table scans.
fn build_alias_map(plan: &LogicalPlan) -> std::collections::HashMap<String, String> {
    let mut map = std::collections::HashMap::new();
    build_alias_map_inner(plan, &mut map);

    // Resolve transitive aliases (e.g., renamed -> source -> raw_users)
    let mut changed = true;
    while changed {
        changed = false;
        let keys: Vec<String> = map.keys().cloned().collect();
        for key in keys {
            let value = map[&key].clone();
            if let Some(deeper) = map.get(&value) {
                if *deeper != value {
                    map.insert(key, deeper.clone());
                    changed = true;
                }
            }
        }
    }

    map
}

fn build_alias_map_inner(
    plan: &LogicalPlan,
    map: &mut std::collections::HashMap<String, String>,
) {
    match plan {
        LogicalPlan::SubqueryAlias(alias) => {
            let alias_name = alias.alias.to_string();
            // Find the first table scan or subquery alias in the input
            if let Some(table_name) = find_leaf_table(&alias.input) {
                map.insert(alias_name, table_name);
            }
            build_alias_map_inner(&alias.input, map);
        }
        _ => {
            for child in plan.inputs() {
                build_alias_map_inner(child, map);
            }
        }
    }
}

/// Find the first/primary table name referenced in a plan subtree.
fn find_leaf_table(plan: &LogicalPlan) -> Option<String> {
    match plan {
        LogicalPlan::TableScan(scan) => Some(scan.table_name.to_string()),
        LogicalPlan::SubqueryAlias(alias) => Some(alias.alias.to_string()),
        LogicalPlan::Projection(proj) => find_leaf_table(&proj.input),
        LogicalPlan::Filter(f) => find_leaf_table(&f.input),
        LogicalPlan::Sort(s) => find_leaf_table(&s.input),
        LogicalPlan::Limit(l) => find_leaf_table(&l.input),
        _ => plan.inputs().first().and_then(|c| find_leaf_table(c)),
    }
}

/// Resolve a column qualifier to a source table name.
/// Checks alias mappings, direct table names, then falls back.
fn resolve_source_table(
    qualifier: Option<&str>,
    table_names: &[String],
    alias_map: &std::collections::HashMap<String, String>,
) -> String {
    if let Some(q) = qualifier {
        // Check alias map first (CTE names -> underlying tables)
        if let Some(resolved) = alias_map.get(q) {
            return resolved.clone();
        }
        // Check if qualifier directly matches a table name
        for table in table_names {
            if table == q || table.ends_with(&format!(".{q}")) {
                return table.clone();
            }
        }
        // Return the qualifier as-is
        q.to_string()
    } else if table_names.len() == 1 {
        // Unqualified column with single source table
        table_names[0].clone()
    } else {
        "unknown".to_string()
    }
}

/// Extract scan dependencies (WHERE, JOIN ON conditions) from a plan.
fn extract_scan_deps(
    plan: &LogicalPlan,
    model_name: &str,
    table_names: &[String],
    alias_map: &std::collections::HashMap<String, String>,
    edges: &mut Vec<ColumnLineage>,
) {
    let mut seen = HashSet::new();

    match plan {
        LogicalPlan::Filter(filter) => {
            let cols = extract_column_refs(&filter.predicate);
            for (qualifier, col_name) in &cols {
                let source = resolve_source_table(qualifier.as_deref(), table_names, alias_map);
                let key = (source.clone(), col_name.clone());
                if seen.insert(key) {
                    edges.push(ColumnLineage {
                        source_node: source,
                        source_column: col_name.clone(),
                        target_node: model_name.to_string(),
                        target_column: "*".to_string(),
                        dependency_type: DependencyType::Scan,
                    });
                }
            }
            extract_scan_deps(&filter.input, model_name, table_names, alias_map, edges);
        }
        LogicalPlan::Join(join) => {
            if let Some(ref on_expr) = join.filter {
                let cols = extract_column_refs(on_expr);
                for (qualifier, col_name) in &cols {
                    let source = resolve_source_table(qualifier.as_deref(), table_names, alias_map);
                    let key = (source.clone(), col_name.clone());
                    if seen.insert(key) {
                        edges.push(ColumnLineage {
                            source_node: source,
                            source_column: col_name.clone(),
                            target_node: model_name.to_string(),
                            target_column: "*".to_string(),
                            dependency_type: DependencyType::Scan,
                        });
                    }
                }
            }
            for (left, right) in &join.on {
                for expr in [left, right] {
                    let cols = extract_column_refs(expr);
                    for (qualifier, col_name) in &cols {
                        let source = resolve_source_table(qualifier.as_deref(), table_names, alias_map);
                        let key = (source.clone(), col_name.clone());
                        if seen.insert(key) {
                            edges.push(ColumnLineage {
                                source_node: source,
                                source_column: col_name.clone(),
                                target_node: model_name.to_string(),
                                target_column: "*".to_string(),
                                dependency_type: DependencyType::Scan,
                            });
                        }
                    }
                }
            }
            extract_scan_deps(&join.left, model_name, table_names, alias_map, edges);
            extract_scan_deps(&join.right, model_name, table_names, alias_map, edges);
        }
        LogicalPlan::Aggregate(agg) => {
            // Group by columns are scan dependencies
            for expr in &agg.group_expr {
                let cols = extract_column_refs(expr);
                for (qualifier, col_name) in &cols {
                    let source = resolve_source_table(qualifier.as_deref(), table_names, alias_map);
                    let key = (source.clone(), col_name.clone());
                    if seen.insert(key) {
                        edges.push(ColumnLineage {
                            source_node: source,
                            source_column: col_name.clone(),
                            target_node: model_name.to_string(),
                            target_column: "*".to_string(),
                            dependency_type: DependencyType::Scan,
                        });
                    }
                }
            }
            extract_scan_deps(&agg.input, model_name, table_names, alias_map, edges);
        }
        _ => {
            for child in plan.inputs() {
                extract_scan_deps(child, model_name, table_names, alias_map, edges);
            }
        }
    }
}
