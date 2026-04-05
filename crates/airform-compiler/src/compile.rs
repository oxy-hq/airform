use airform_core::{
    InjectedCte, Manifest, ManifestNode, Materialization, UniqueId,
};
use airform_graph::DbtGraph;
use airform_jinja::{DbtContext, JinjaEngine};

/// The compiler resolves refs/sources and produces compiled SQL for each node.
pub struct Compiler {
    engine: JinjaEngine,
}

impl Compiler {
    pub fn new(engine: JinjaEngine) -> Self {
        Self { engine }
    }

    /// Compile all nodes in the manifest in topological order.
    pub fn compile(
        &self,
        manifest: &mut Manifest,
        graph: &DbtGraph,
        ctx_template: &DbtContext,
    ) -> anyhow::Result<CompileResult> {
        let order = graph.topological_sort()?;
        let mut compiled_count = 0;
        let mut errors = Vec::new();

        for unique_id in &order {
            // Skip sources (they don't need compilation)
            if manifest.sources.contains_key(unique_id) {
                continue;
            }

            let Some(node) = manifest.nodes.get(unique_id) else {
                continue;
            };

            match node {
                ManifestNode::Model(model) => {
                    let model = model.clone();
                    match self.compile_model(&model, manifest, ctx_template) {
                        Ok(compiled_sql) => {
                            // For incremental models, also compile a full-refresh variant
                            // (with is_incremental()=false) for first-run when table doesn't exist
                            let full_refresh_sql = if model.config.materialized == Materialization::Incremental
                                && !ctx_template.full_refresh
                            {
                                let mut fr_ctx = ctx_template.clone();
                                fr_ctx.full_refresh = true;
                                self.compile_model(&model, manifest, &fr_ctx).ok()
                            } else {
                                None
                            };

                            if let Some(ManifestNode::Model(m)) =
                                manifest.nodes.get_mut(unique_id)
                            {
                                m.compiled_sql = Some(compiled_sql);
                                m.compiled_sql_full_refresh = full_refresh_sql;
                            }
                            compiled_count += 1;
                        }
                        Err(e) => {
                            errors.push(CompileError {
                                node_id: unique_id.clone(),
                                message: format!("{:#}", e),
                            });
                        }
                    }
                }
                ManifestNode::Snapshot(snapshot) => {
                    let snapshot = snapshot.clone();
                    match self.compile_snapshot(&snapshot, manifest, ctx_template) {
                        Ok(compiled_sql) => {
                            if let Some(ManifestNode::Snapshot(s)) =
                                manifest.nodes.get_mut(unique_id)
                            {
                                s.compiled_sql = Some(compiled_sql);
                            }
                            compiled_count += 1;
                        }
                        Err(e) => {
                            errors.push(CompileError {
                                node_id: unique_id.clone(),
                                message: e.to_string(),
                            });
                        }
                    }
                }
                _ => {}
            }
        }

        Ok(CompileResult {
            compiled_count,
            errors,
        })
    }

    /// Compile a single model: render Jinja with resolved refs/sources,
    /// then inject ephemeral CTEs.
    fn compile_model(
        &self,
        model: &airform_core::ModelNode,
        manifest: &Manifest,
        ctx_template: &DbtContext,
    ) -> anyhow::Result<String> {
        // Build context with resolved refs and sources
        let mut ctx = ctx_template.clone();
        ctx.execute = true;

        // Set incremental context: is_incremental is true when model is incremental
        // and we're not doing a full refresh (matches dbt behavior at compile time)
        if model.config.materialized == Materialization::Incremental && !ctx.full_refresh {
            ctx.is_incremental = true;
        }

        // Set `this` relation to the model's resolved relation name (quoted for safety)
        let is_local = ctx_template.target_type == "datafusion" || ctx_template.target_type == "duckdb";
        let this_name = model.config.alias.as_deref().unwrap_or(&model.name);
        ctx.this_relation = Some(if is_local {
            this_name.to_string()
        } else {
            let schema = model.config.schema.as_deref().unwrap_or(&ctx_template.target_schema);
            format!("\"{schema}\".\"{this_name}\"")
        });

        // Resolve all ref() calls to relation names
        for ref_call in &model.depends_on.refs {
            if let Some(target) = manifest.resolve_ref(
                &ref_call.model_name,
                ref_call.package.as_deref(),
            ) {
                let relation = self.node_relation_name(target, ctx_template);
                ctx.ref_resolutions
                    .insert(ref_call.model_name.clone(), relation);
            }
        }

        // Resolve all source() calls
        let is_local = ctx_template.target_type == "datafusion" || ctx_template.target_type == "duckdb";
        for source_call in &model.depends_on.sources {
            if let Some(source) = manifest.resolve_source(
                &source_call.source_name,
                &source_call.table_name,
            ) {
                let relation = if is_local {
                    // For local execution (DataFusion/DuckDB), use just the table name
                    // since seeds/tables are registered in a flat namespace
                    source.table_identifier().to_string()
                } else {
                    source.relation_name()
                };
                ctx.source_resolutions.insert(
                    (source_call.source_name.clone(), source_call.table_name.clone()),
                    relation,
                );
            }
        }

        // Render Jinja
        let rendered = self.engine.render(&model.raw_sql, &ctx)?;

        // Inject ephemeral CTEs
        let compiled = self.inject_ephemeral_ctes(&rendered, model, manifest, ctx_template)?;

        Ok(compiled)
    }

    /// Compile a single snapshot: render Jinja with resolved refs/sources.
    fn compile_snapshot(
        &self,
        snapshot: &airform_core::SnapshotNode,
        manifest: &Manifest,
        ctx_template: &DbtContext,
    ) -> anyhow::Result<String> {
        let mut ctx = ctx_template.clone();
        ctx.execute = true;

        // Resolve all ref() calls to relation names
        for ref_call in &snapshot.depends_on.refs {
            if let Some(target) = manifest.resolve_ref(
                &ref_call.model_name,
                ref_call.package.as_deref(),
            ) {
                let relation = self.node_relation_name(target, ctx_template);
                ctx.ref_resolutions
                    .insert(ref_call.model_name.clone(), relation);
            }
        }

        // Resolve all source() calls
        let is_local = ctx_template.target_type == "datafusion" || ctx_template.target_type == "duckdb";
        for source_call in &snapshot.depends_on.sources {
            if let Some(source) = manifest.resolve_source(
                &source_call.source_name,
                &source_call.table_name,
            ) {
                let relation = if is_local {
                    source.table_identifier().to_string()
                } else {
                    source.relation_name()
                };
                ctx.source_resolutions.insert(
                    (source_call.source_name.clone(), source_call.table_name.clone()),
                    relation,
                );
            }
        }

        // Render Jinja
        let rendered = self.engine.render(&snapshot.raw_sql, &ctx)?;

        Ok(rendered)
    }

    /// For ephemeral dependencies, wrap them as CTEs prepended to the SQL.
    /// Handles recursive ephemeral deps by flattening all CTEs into a single WITH block.
    fn inject_ephemeral_ctes(
        &self,
        sql: &str,
        model: &airform_core::ModelNode,
        manifest: &Manifest,
        _ctx_template: &DbtContext,
    ) -> anyhow::Result<String> {
        let mut ctes: Vec<InjectedCte> = Vec::new();
        let mut seen = std::collections::HashSet::new();

        // Recursively collect all ephemeral CTEs (depth-first)
        self.collect_ephemeral_ctes(model, manifest, &mut ctes, &mut seen);

        if ctes.is_empty() {
            return Ok(sql.to_string());
        }

        // Deduplicate CTEs by name (first occurrence wins)
        let mut seen_names = std::collections::HashSet::new();
        ctes.retain(|cte| {
            // Extract CTE name (the part before " as (")
            let name = cte.sql.split_whitespace().next().unwrap_or("");
            seen_names.insert(name.to_string())
        });

        // Build WITH clause from collected CTEs
        let cte_block: Vec<String> = ctes.iter().map(|c| c.sql.clone()).collect();
        let with_clause = format!("with {}", cte_block.join(",\n"));

        // Merge with existing WITH clause if present
        let trimmed = sql.trim();
        let stripped = strip_leading_comments(trimmed);
        let compiled = if stripped.to_uppercase().starts_with("WITH") {
            // Find where "with" is in the original trimmed string
            let with_offset = trimmed.len() - stripped.len();
            let leading = &trimmed[..with_offset]; // preserve comments
            let after_with = stripped[4..].trim(); // skip "WITH"
            format!("{leading}{with_clause},\n{after_with}")
        } else {
            format!("{with_clause}\n{trimmed}")
        };

        Ok(compiled)
    }

    /// Recursively collect ephemeral CTEs, extracting internal CTEs and
    /// the final SELECT to produce a flat CTE chain.
    fn collect_ephemeral_ctes(
        &self,
        model: &airform_core::ModelNode,
        manifest: &Manifest,
        ctes: &mut Vec<InjectedCte>,
        seen: &mut std::collections::HashSet<String>,
    ) {
        for ref_call in &model.depends_on.refs {
            if let Some(ManifestNode::Model(target_model)) = manifest.resolve_ref(
                &ref_call.model_name,
                ref_call.package.as_deref(),
            ) {
                if target_model.config.materialized != Materialization::Ephemeral {
                    continue;
                }
                if !seen.insert(target_model.unique_id.clone()) {
                    continue;
                }

                // First, recursively collect CTEs from this ephemeral's own deps
                self.collect_ephemeral_ctes(target_model, manifest, ctes, seen);

                // Get the compiled SQL for this ephemeral model
                let full_sql = target_model
                    .compiled_sql
                    .as_deref()
                    .unwrap_or(&target_model.raw_sql);

                // Extract internal CTEs and the final SELECT body
                let (internal_ctes, select_body) = extract_ctes_and_body(full_sql);

                // Add any internal CTEs (e.g., from the ephemeral model's own WITH clause)
                for (cte_name, cte_body) in internal_ctes {
                    let cte_id = format!("inline.{}", cte_name);
                    if seen.insert(cte_id.clone()) {
                        ctes.push(InjectedCte {
                            id: cte_id,
                            sql: format!("{cte_name} as (\n{cte_body}\n)"),
                        });
                    }
                }

                // Add the ephemeral model itself as a CTE using just the SELECT body
                ctes.push(InjectedCte {
                    id: target_model.unique_id.clone(),
                    sql: format!(
                        "__dbt__cte__{} as (\n{}\n)",
                        target_model.name, select_body
                    ),
                });
            }
        }
    }

    /// Get the relation name for a node.
    /// For local execution (DataFusion/DuckDB), uses just the table name.
    /// For remote execution, uses schema.table.
    fn node_relation_name(&self, node: &ManifestNode, ctx: &DbtContext) -> String {
        let is_local = ctx.target_type == "datafusion" || ctx.target_type == "duckdb";

        match node {
            ManifestNode::Model(m) => {
                let table_name = m.config.alias.as_deref().unwrap_or(&m.name);

                // For ephemeral models, return the CTE reference
                if m.config.materialized == Materialization::Ephemeral {
                    return format!("__dbt__cte__{}", m.name);
                }

                if is_local {
                    table_name.to_string()
                } else {
                    let schema = m.config.schema.as_deref().unwrap_or(&ctx.target_schema);
                    format!("{schema}.{table_name}")
                }
            }
            ManifestNode::Seed(s) => {
                if is_local {
                    s.name.clone()
                } else {
                    let schema = s.config.schema.as_deref().unwrap_or(&ctx.target_schema);
                    format!("{schema}.{}", s.name)
                }
            }
            ManifestNode::Snapshot(s) => {
                if is_local {
                    s.name.clone()
                } else {
                    let schema = s.config.schema.as_deref().unwrap_or(&ctx.target_schema);
                    format!("{schema}.{}", s.name)
                }
            }
            _ => "unknown".to_string(),
        }
    }
}

/// Result of compilation
#[derive(Debug)]
pub struct CompileResult {
    pub compiled_count: usize,
    pub errors: Vec<CompileError>,
}

#[derive(Debug)]
pub struct CompileError {
    pub node_id: UniqueId,
    pub message: String,
}

/// Strip leading SQL comments (-- line comments and /* block comments */) and whitespace.
fn strip_leading_comments(sql: &str) -> &str {
    let mut s = sql.trim();
    loop {
        if s.starts_with("--") {
            // Skip to end of line
            if let Some(nl) = s.find('\n') {
                s = s[nl + 1..].trim();
            } else {
                return ""; // entire string is a comment
            }
        } else if s.starts_with("/*") {
            if let Some(end) = s.find("*/") {
                s = s[end + 2..].trim();
            } else {
                return ""; // unclosed block comment
            }
        } else {
            return s;
        }
    }
}

/// Extract internal CTEs and the final SELECT body from a SQL string.
/// Returns (Vec<(cte_name, cte_body)>, select_body).
/// Given `WITH a AS (SELECT 1), b AS (SELECT 2) SELECT * FROM a, b`,
/// returns `([("a", "SELECT 1"), ("b", "SELECT 2")], "SELECT * FROM a, b")`.
fn extract_ctes_and_body(sql: &str) -> (Vec<(String, String)>, String) {
    // Strip leading comments (-- and /* */) to find the actual WITH
    let trimmed = strip_leading_comments(sql.trim());
    if !trimmed.to_uppercase().starts_with("WITH") {
        return (Vec::new(), sql.trim().to_string());
    }

    // Find the final SELECT at depth 0
    let mut depth: i32 = 0;
    let upper = trimmed.to_uppercase();
    let bytes = upper.as_bytes();
    let mut final_select_pos = None;

    for i in 0..bytes.len() {
        match bytes[i] {
            b'(' => depth += 1,
            b')' => depth -= 1,
            b'S' if depth == 0 && i > 4 => {
                if upper[i..].starts_with("SELECT") {
                    let prev = bytes[i - 1];
                    if prev == b' ' || prev == b'\n' || prev == b'\r' || prev == b'\t' {
                        final_select_pos = Some(i);
                    }
                }
            }
            _ => {}
        }
    }

    let Some(select_pos) = final_select_pos else {
        return (Vec::new(), trimmed.to_string());
    };

    let select_body = trimmed[select_pos..].to_string();
    let with_block = trimmed[4..select_pos].trim(); // skip "WITH"

    // Parse individual CTEs from the with block
    let mut ctes = Vec::new();
    let mut pos = 0;
    let with_bytes = with_block.as_bytes();

    while pos < with_bytes.len() {
        // Skip whitespace and commas
        while pos < with_bytes.len()
            && (with_bytes[pos] == b' '
                || with_bytes[pos] == b'\n'
                || with_bytes[pos] == b'\r'
                || with_bytes[pos] == b'\t'
                || with_bytes[pos] == b',')
        {
            pos += 1;
        }
        if pos >= with_bytes.len() {
            break;
        }

        // Read CTE name
        let name_start = pos;
        while pos < with_bytes.len()
            && with_bytes[pos] != b' '
            && with_bytes[pos] != b'\n'
            && with_bytes[pos] != b'\t'
        {
            pos += 1;
        }
        let cte_name = &with_block[name_start..pos];

        // Skip whitespace + "AS" + whitespace
        while pos < with_bytes.len() && (with_bytes[pos] == b' ' || with_bytes[pos] == b'\n' || with_bytes[pos] == b'\t' || with_bytes[pos] == b'\r') {
            pos += 1;
        }
        let upper_rest = with_block[pos..].to_uppercase();
        if upper_rest.starts_with("AS") {
            pos += 2;
        }
        while pos < with_bytes.len() && (with_bytes[pos] == b' ' || with_bytes[pos] == b'\n' || with_bytes[pos] == b'\t' || with_bytes[pos] == b'\r') {
            pos += 1;
        }

        // Find matching parens for the CTE body
        if pos < with_bytes.len() && with_bytes[pos] == b'(' {
            pos += 1;
            let body_start = pos;
            let mut paren_depth = 1;
            while pos < with_bytes.len() && paren_depth > 0 {
                match with_bytes[pos] {
                    b'(' => paren_depth += 1,
                    b')' => paren_depth -= 1,
                    _ => {}
                }
                if paren_depth > 0 {
                    pos += 1;
                }
            }
            let body = with_block[body_start..pos].trim();
            ctes.push((cte_name.to_string(), body.to_string()));
            pos += 1; // skip closing paren
        } else {
            // Malformed, skip
            break;
        }
    }

    (ctes, select_body)
}

impl std::fmt::Display for CompileResult {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "Compiled {} models ({} errors)",
            self.compiled_count,
            self.errors.len()
        )
    }
}
