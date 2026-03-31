use airform_core::{Manifest, ManifestNode};
use regex::Regex;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Type of column dependency
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

/// A single column-level lineage edge
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColumnLineage {
    pub source_node: String,
    pub source_column: String,
    pub target_node: String,
    pub target_column: String,
    pub dependency_type: DependencyType,
}

/// Result of column lineage analysis for an entire project
#[derive(Debug, Clone, Default)]
pub struct ColumnLineageGraph {
    pub edges: Vec<ColumnLineage>,
}

impl ColumnLineageGraph {
    /// Get all lineage edges for a specific target column
    pub fn edges_for_column(&self, target_node: &str, target_column: &str) -> Vec<&ColumnLineage> {
        self.edges
            .iter()
            .filter(|e| e.target_node == target_node && e.target_column == target_column)
            .collect()
    }

    /// Trace the full lineage of a column back through the entire DAG
    pub fn trace_column(&self, target_node: &str, target_column: &str) -> Vec<&ColumnLineage> {
        let mut result = Vec::new();
        let mut stack: Vec<(&str, &str)> = vec![(target_node, target_column)];
        let mut visited = std::collections::HashSet::new();

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

/// Build column-level lineage for the entire manifest.
///
/// This uses regex-based SQL analysis to extract column references from
/// compiled (or raw) SQL and map them to upstream models/sources.
pub fn build_column_lineage(manifest: &Manifest) -> ColumnLineageGraph {
    let mut graph = ColumnLineageGraph::default();

    // Build a map of model_name -> unique_id for resolving refs
    let mut name_to_id: HashMap<String, String> = HashMap::new();
    for (id, node) in &manifest.nodes {
        name_to_id.insert(node.name().to_string(), id.clone());
    }
    for (id, source) in &manifest.sources {
        let source_key = format!("{}.{}", source.source_name, source.name);
        name_to_id.insert(source_key, id.clone());
    }

    for (_id, node) in &manifest.nodes {
        if let ManifestNode::Model(model) = node {
            let sql = model
                .compiled_sql
                .as_deref()
                .unwrap_or(&model.raw_sql);

            // Build a mapping of CTE/alias name -> upstream node name
            let mut alias_to_upstream: HashMap<String, String> = HashMap::new();

            // Extract CTE definitions that reference upstream models
            // Pattern: alias as ( select ... from upstream_ref )
            for ref_call in &model.depends_on.refs {
                alias_to_upstream.insert(
                    ref_call.model_name.clone(),
                    ref_call.model_name.clone(),
                );
                // Also map __dbt__cte__name patterns
                alias_to_upstream.insert(
                    format!("__dbt__cte__{}", ref_call.model_name),
                    ref_call.model_name.clone(),
                );
            }
            for source_call in &model.depends_on.sources {
                let key = format!("{}.{}", source_call.source_name, source_call.table_name);
                alias_to_upstream.insert(key.clone(), key.clone());
                alias_to_upstream.insert(
                    source_call.table_name.clone(),
                    key,
                );
            }

            // Parse CTE aliases: `alias as (` ... references
            let cte_re = Regex::new(r"(?i)\b(\w+)\s+as\s*\(\s*select").unwrap();
            let from_re = Regex::new(r"(?i)\bfrom\s+(\w+(?:\.\w+)?)").unwrap();

            // For each CTE, find what it selects from
            for cte_cap in cte_re.captures_iter(sql) {
                let cte_name = cte_cap[1].to_string();
                // Find the body of this CTE - look for FROM clauses after the CTE definition
                let cte_start = cte_cap.get(0).unwrap().start();
                // Find the matching closing paren (simplified: look for next CTE or end)
                let rest = &sql[cte_start..];
                for from_cap in from_re.captures_iter(rest) {
                    let from_table = from_cap[1].to_string();
                    // Try exact match first
                    if let Some(upstream) = alias_to_upstream.get(&from_table) {
                        alias_to_upstream.insert(cte_name.clone(), upstream.clone());
                        break;
                    }
                    // Try matching schema.table -> table (e.g., main.stg_customers -> stg_customers)
                    if let Some((_schema, table)) = from_table.split_once('.') {
                        if let Some(upstream) = alias_to_upstream.get(table) {
                            alias_to_upstream.insert(cte_name.clone(), upstream.clone());
                            break;
                        }
                    }
                }
            }

            // Resolve multi-hop CTE aliases (e.g., customer_payments -> payments -> stg_payments)
            // Iterate until stable
            let mut changed = true;
            while changed {
                changed = false;
                let keys: Vec<String> = alias_to_upstream.keys().cloned().collect();
                for key in keys {
                    let value = alias_to_upstream[&key].clone();
                    if let Some(deeper) = alias_to_upstream.get(&value) {
                        if *deeper != value && alias_to_upstream[&key] != *deeper {
                            alias_to_upstream.insert(key, deeper.clone());
                            changed = true;
                        }
                    }
                }
            }

            // Now extract column lineage from the SQL
            let edges = extract_column_references(
                sql,
                &model.name,
                &model.unique_id,
                &alias_to_upstream,
                &name_to_id,
                manifest,
            );
            graph.edges.extend(edges);
        }
    }

    graph
}

/// Extract column references from a SQL statement using regex-based analysis.
fn extract_column_references(
    sql: &str,
    model_name: &str,
    _model_id: &str,
    alias_to_upstream: &HashMap<String, String>,
    name_to_id: &HashMap<String, String>,
    manifest: &Manifest,
) -> Vec<ColumnLineage> {
    let mut edges = Vec::new();

    let _upper_sql = sql.to_uppercase();

    // Find the final SELECT block (the one that defines the output columns).
    // Heuristic: the last SELECT ... FROM pattern in the SQL
    let select_blocks = find_select_blocks(sql);
    let final_block = select_blocks.last();

    if let Some(block) = final_block {
        // Extract columns from the final SELECT
        let select_columns = parse_select_columns(&block.select_clause);

        for col_expr in &select_columns {
            // Determine target column name:
            // - If aliased: use alias
            // - If qualified (table.col): use just the column part
            // - Otherwise: use the expression
            let target_col = if let Some(alias) = col_expr.alias.as_deref() {
                alias.to_string()
            } else if let Some((_table, col)) = col_expr.expression.split_once('.') {
                col.to_string()
            } else {
                col_expr.expression.clone()
            };
            let target_col = target_col.as_str();

            // Try to resolve table.column references
            let qualified_re = Regex::new(r"(?i)\b(\w+)\.(\w+)\b").unwrap();
            let mut found_refs = Vec::new();

            for cap in qualified_re.captures_iter(&col_expr.expression) {
                let table_alias = cap[1].to_string();
                let column_name = cap[2].to_string();
                found_refs.push((table_alias, column_name));
            }

            if found_refs.is_empty() {
                // Unqualified column reference: check if it's a plain column name
                let bare_col_re = Regex::new(r"(?i)^(\w+)$").unwrap();
                if let Some(cap) = bare_col_re.captures(col_expr.expression.trim()) {
                    let col_name = cap[1].to_string();
                    // Check if it's a SQL keyword or literal
                    if !is_sql_keyword(&col_name) {
                        // Try to find which upstream source has this column
                        for (_alias, upstream_name) in alias_to_upstream {
                            if let Some(upstream_id) = name_to_id.get(upstream_name) {
                                if source_has_column(manifest, upstream_id, &col_name) {
                                    edges.push(ColumnLineage {
                                        source_node: upstream_name.clone(),
                                        source_column: col_name.clone(),
                                        target_node: model_name.to_string(),
                                        target_column: target_col.to_string(),
                                        dependency_type: DependencyType::Copy,
                                    });
                                    break;
                                }
                            }
                        }
                    }
                }
            } else {
                // Determine dependency type
                let dep_type = if found_refs.len() == 1 && col_expr.is_simple {
                    DependencyType::Copy
                } else {
                    DependencyType::Transform
                };

                for (table_alias, column_name) in &found_refs {
                    if let Some(upstream_name) = alias_to_upstream.get(table_alias) {
                        edges.push(ColumnLineage {
                            source_node: upstream_name.clone(),
                            source_column: column_name.clone(),
                            target_node: model_name.to_string(),
                            target_column: target_col.to_string(),
                            dependency_type: dep_type.clone(),
                        });
                    }
                }
            }
        }
    }

    // Extract scan dependencies (WHERE, JOIN ON, GROUP BY)
    let scan_patterns = [
        Regex::new(r"(?i)\bwhere\b(.+?)(?:\bgroup\b|\border\b|\blimit\b|\bhaving\b|\bunion\b|$)").unwrap(),
        Regex::new(r"(?i)\bon\b\s+(.+?)(?:\bwhere\b|\bgroup\b|\border\b|\bleft\b|\bright\b|\binner\b|\bjoin\b|\bcross\b|\bfull\b|$)").unwrap(),
        Regex::new(r"(?i)\bgroup\s+by\b\s+(.+?)(?:\bhaving\b|\border\b|\blimit\b|$)").unwrap(),
    ];

    let qualified_re = Regex::new(r"(?i)\b(\w+)\.(\w+)\b").unwrap();
    for pattern in &scan_patterns {
        for cap in pattern.captures_iter(sql) {
            let clause = &cap[1];
            for col_cap in qualified_re.captures_iter(clause) {
                let table_alias = col_cap[1].to_string();
                let column_name = col_cap[2].to_string();
                if let Some(upstream_name) = alias_to_upstream.get(&table_alias) {
                    // Only add if we don't already have this exact edge
                    let exists = edges.iter().any(|e| {
                        e.source_node == *upstream_name
                            && e.source_column == column_name
                            && e.target_node == model_name
                            && e.dependency_type == DependencyType::Scan
                    });
                    if !exists {
                        edges.push(ColumnLineage {
                            source_node: upstream_name.clone(),
                            source_column: column_name.clone(),
                            target_node: model_name.to_string(),
                            target_column: "*".to_string(),
                            dependency_type: DependencyType::Scan,
                        });
                    }
                }
            }
        }
    }

    edges
}

struct SelectBlock {
    select_clause: String,
    #[allow(dead_code)]
    from_clause: String,
}

struct ColumnExpression {
    expression: String,
    alias: Option<String>,
    is_simple: bool,
}

fn find_select_blocks(sql: &str) -> Vec<SelectBlock> {
    let mut blocks = Vec::new();
    let select_re = Regex::new(r"(?i)\bselect\b").unwrap();
    let from_re = Regex::new(r"(?i)\bfrom\b").unwrap();

    let select_positions: Vec<usize> = select_re.find_iter(sql).map(|m| m.end()).collect();

    for select_end in &select_positions {
        let rest = &sql[*select_end..];
        if let Some(from_match) = from_re.find(rest) {
            let select_clause = rest[..from_match.start()].trim().to_string();
            let from_clause = rest[from_match.end()..].trim().to_string();
            // Skip "select *" blocks
            if select_clause.trim() != "*" {
                blocks.push(SelectBlock {
                    select_clause,
                    from_clause,
                });
            }
        }
    }

    blocks
}

fn parse_select_columns(select_clause: &str) -> Vec<ColumnExpression> {
    let mut columns = Vec::new();

    // Split on commas, but respect parentheses
    let parts = split_columns(select_clause);

    for part in parts {
        let trimmed = part.trim();
        if trimmed.is_empty() || trimmed == "*" {
            continue;
        }

        // Check for alias: expr AS alias
        let alias_re = Regex::new(r"(?i)\s+as\s+(\w+)\s*$").unwrap();
        let (expression, alias) = if let Some(cap) = alias_re.captures(trimmed) {
            let alias = cap[1].to_string();
            let expr_end = cap.get(0).unwrap().start();
            (trimmed[..expr_end].trim().to_string(), Some(alias))
        } else {
            // Could be `expression alias` (without AS)
            let words: Vec<&str> = trimmed.split_whitespace().collect();
            if words.len() >= 2 {
                let last_word = words.last().unwrap();
                // Check if last word looks like an alias (not a keyword)
                if !is_sql_keyword(last_word)
                    && Regex::new(r"^[a-zA-Z_]\w*$").unwrap().is_match(last_word)
                    && !last_word.contains('.')
                {
                    let expr = words[..words.len() - 1].join(" ");
                    (expr, Some(last_word.to_string()))
                } else {
                    (trimmed.to_string(), None)
                }
            } else {
                (trimmed.to_string(), None)
            }
        };

        // Determine if this is a simple column reference (no functions, operators)
        let is_simple = Regex::new(r"(?i)^(\w+\.)?(\w+)$")
            .unwrap()
            .is_match(expression.trim());

        columns.push(ColumnExpression {
            expression,
            alias,
            is_simple,
        });
    }

    columns
}

fn split_columns(clause: &str) -> Vec<String> {
    let mut parts = Vec::new();
    let mut current = String::new();
    let mut paren_depth = 0;

    for ch in clause.chars() {
        match ch {
            '(' => {
                paren_depth += 1;
                current.push(ch);
            }
            ')' => {
                paren_depth -= 1;
                current.push(ch);
            }
            ',' if paren_depth == 0 => {
                parts.push(current.clone());
                current.clear();
            }
            _ => current.push(ch),
        }
    }
    if !current.trim().is_empty() {
        parts.push(current);
    }

    parts
}

fn is_sql_keyword(word: &str) -> bool {
    let keywords = [
        "SELECT", "FROM", "WHERE", "AND", "OR", "NOT", "NULL", "TRUE", "FALSE", "AS", "ON",
        "JOIN", "LEFT", "RIGHT", "INNER", "OUTER", "FULL", "CROSS", "GROUP", "BY", "ORDER",
        "HAVING", "LIMIT", "OFFSET", "UNION", "ALL", "DISTINCT", "CASE", "WHEN", "THEN", "ELSE",
        "END", "IN", "EXISTS", "BETWEEN", "LIKE", "IS", "ASC", "DESC", "WITH", "INSERT", "INTO",
        "UPDATE", "DELETE", "CREATE", "DROP", "ALTER", "TABLE", "VIEW", "INDEX", "SET", "VALUES",
        "COUNT", "SUM", "AVG", "MIN", "MAX", "COALESCE", "CAST", "OVER", "PARTITION", "ROW",
        "ROWS", "RANGE", "UNBOUNDED", "PRECEDING", "FOLLOWING", "CURRENT",
    ];
    keywords.contains(&word.to_uppercase().as_str())
}

fn source_has_column(manifest: &Manifest, node_id: &str, column_name: &str) -> bool {
    let col_lower = column_name.to_lowercase();
    if let Some(node) = manifest.nodes.get(node_id) {
        match node {
            ManifestNode::Model(m) => {
                return m.columns.iter().any(|c| c.name.to_lowercase() == col_lower);
            }
            _ => {}
        }
    }
    if let Some(source) = manifest.sources.get(node_id) {
        return source
            .columns
            .iter()
            .any(|c| c.name.to_lowercase() == col_lower);
    }
    false
}
