use airform_core::{Manifest, ManifestNode, Materialization, TestDef, UniqueId};
use airform_graph::DbtGraph;
use datafusion::prelude::*;
use std::path::{Path, PathBuf};
use std::time::{Duration, Instant};

/// Normalize timestamps in a CSV file to handle non-standard formats.
/// Returns the original path if no changes needed, or a temp file path.
/// Fixes: single-digit hours like "2016-06-25 0:54:37" → "2016-06-25 00:54:37"
fn normalize_csv_timestamps(csv_path: &Path) -> anyhow::Result<PathBuf> {
    let content = std::fs::read_to_string(csv_path)?;

    // Quick check: does the content contain a timestamp with single-digit hour?
    // Pattern: date separator, space, single digit, colon
    // e.g. "2016-06-25 0:54:37" or "2019-08-14 4:26:19"
    let needs_fix = content.contains(" 0:") || content.contains(" 1:")
        || content.contains(" 2:") || content.contains(" 3:")
        || content.contains(" 4:") || content.contains(" 5:")
        || content.contains(" 6:") || content.contains(" 7:")
        || content.contains(" 8:") || content.contains(" 9:");

    if !needs_fix {
        return Ok(csv_path.to_path_buf());
    }

    // More precise check: only fix timestamp-like patterns
    let mut fixed = String::with_capacity(content.len() + 256);
    let chars: Vec<char> = content.chars().collect();
    let mut i = 0;
    while i < chars.len() {
        // Look for pattern: YYYY-MM-DD H:MM:SS (where H is a single digit)
        // Preceded by comma, quote, or start-of-field context
        if i + 18 < chars.len()
            && chars[i].is_ascii_digit() && chars[i + 1].is_ascii_digit()
            && chars[i + 2].is_ascii_digit() && chars[i + 3].is_ascii_digit()
            && chars[i + 4] == '-'
            && chars[i + 5].is_ascii_digit() && chars[i + 6].is_ascii_digit()
            && chars[i + 7] == '-'
            && chars[i + 8].is_ascii_digit() && chars[i + 9].is_ascii_digit()
            && chars[i + 10] == ' '
            && chars[i + 11].is_ascii_digit()
            && chars[i + 12] == ':'
        {
            // This is a timestamp with single-digit hour — pad it
            for j in 0..11 {
                fixed.push(chars[i + j]);
            }
            fixed.push('0');
            fixed.push(chars[i + 11]);
            i += 12;
            continue;
        }
        fixed.push(chars[i]);
        i += 1;
    }

    // Write to temp file next to the original
    let temp_path = csv_path.with_extension("_normalized.csv");
    std::fs::write(&temp_path, &fixed)?;
    Ok(temp_path)
}

/// Quote a SQL identifier to prevent injection via model/column names.
/// Doubles any internal double-quotes, then wraps in double-quotes.
fn quote_ident(ident: &str) -> String {
    format!("\"{}\"", ident.replace('"', "\"\""))
}

/// Fix DataFusion compatibility issue: when a table is aliased, the original
/// qualified name cannot be used as a column qualifier. Rewrites
/// `schema.table.* from schema.table as alias` to `alias.* from schema.table as alias`.
fn fix_qualified_aliases(sql: &str) -> String {
    use std::collections::HashMap;

    // Find all `FROM <qualified> AS <alias>` patterns (case-insensitive)
    let sql_lower = sql.to_lowercase();
    let mut replacements: HashMap<String, String> = HashMap::new();

    // Match patterns like `from schema.table as alias` or `from schema.table alias`
    let from_re_patterns = [" from ", "\nfrom ", "\rfrom ", "\tfrom "];
    for from_pat in from_re_patterns {
        let mut search_pos = 0;
        while let Some(from_pos) = sql_lower[search_pos..].find(from_pat) {
            let abs_from = search_pos + from_pos + from_pat.len();
            // Extract the qualified table name (schema.table or catalog.schema.table)
            let rest = &sql[abs_from..];
            let rest_trimmed = rest.trim_start();
            // Find end of qualified name (word.word pattern)
            let mut end = 0;
            let chars: Vec<char> = rest_trimmed.chars().collect();
            while end < chars.len()
                && (chars[end].is_alphanumeric() || chars[end] == '_' || chars[end] == '.')
            {
                end += 1;
            }
            let qualified = &rest_trimmed[..end];
            if !qualified.contains('.') {
                search_pos = abs_from;
                continue;
            }

            // Find "as alias" or just "alias" after the qualified name
            let after_qual = rest_trimmed[end..].trim_start();
            let alias = if after_qual.to_lowercase().starts_with("as ") {
                let after_as = after_qual[3..].trim_start();
                let alias_end = after_as
                    .find(|c: char| !c.is_alphanumeric() && c != '_')
                    .unwrap_or(after_as.len());
                &after_as[..alias_end]
            } else {
                // Check if the next word looks like an alias (not a keyword)
                let alias_end = after_qual
                    .find(|c: char| !c.is_alphanumeric() && c != '_')
                    .unwrap_or(after_qual.len());
                let potential = &after_qual[..alias_end];
                let keywords = [
                    "where", "join", "left", "right", "inner", "outer", "cross", "on",
                    "group", "order", "having", "limit", "union", "except", "intersect",
                    "", "select", "from",
                ];
                if keywords.contains(&potential.to_lowercase().as_str()) {
                    search_pos = abs_from;
                    continue;
                }
                potential
            };

            if !alias.is_empty() && alias.len() < 100 {
                // Replace qualified.* with alias.* and qualified.col with alias.col
                replacements.insert(qualified.to_string(), alias.to_string());
            }
            search_pos = abs_from;
        }
    }

    if replacements.is_empty() {
        return sql.to_string();
    }

    let mut result = sql.to_string();
    // Sort by longest key first to avoid partial replacements
    let mut sorted: Vec<_> = replacements.iter().collect();
    sorted.sort_by(|a, b| b.0.len().cmp(&a.0.len()));

    for (qualified, alias) in sorted {
        // Replace `qualified.*` with `alias.*` and `qualified.col` with `alias.col`
        // But NOT in FROM/JOIN clauses (only in SELECT, WHERE, etc.)
        // Simple approach: replace `qualified.` prefix when followed by column patterns
        let from_pattern = format!("{qualified}.");
        let alias_pattern = format!("{alias}.");

        // Only replace occurrences that are NOT part of a FROM/JOIN table reference
        // i.e., don't replace `from schema.table` but do replace `schema.table.column`
        // This works because FROM references are `schema.table` (no trailing dot)
        result = result.replace(&from_pattern, &alias_pattern);
    }

    result
}

/// Fix various DataFusion SQL compatibility issues:
/// - DATE_DIFF('part', start, end) → date_diff is not built-in; rewrite to
///   EXTRACT(EPOCH FROM ...) for second granularity or date_part subtraction for others
/// - ::TYPE postgres-style casts → CAST(expr AS TYPE)
fn fix_sql_compat(sql: &str) -> String {
    let mut result = sql.to_string();

    // Replace DATE_DIFF('part', start, end) with DataFusion-compatible expression.
    // We do a simple regex-free approach: find DATE_DIFF( and rewrite.
    loop {
        let lower = result.to_lowercase();
        let Some(pos) = lower.find("date_diff(") else {
            break;
        };
        let start = pos + "date_diff(".len();
        // Find the matching closing paren, accounting for nesting
        let bytes = result.as_bytes();
        let mut depth = 1;
        let mut i = start;
        while i < bytes.len() && depth > 0 {
            if bytes[i] == b'(' {
                depth += 1;
            } else if bytes[i] == b')' {
                depth -= 1;
            }
            if depth > 0 {
                i += 1;
            }
        }
        if depth != 0 {
            break;
        }
        let args_str = &result[start..i];
        // Split on top-level commas (not inside parens)
        let args = split_top_level(args_str);
        if args.len() == 3 {
            let part = args[0].trim().trim_matches('\'').trim_matches('"');
            let start_expr = args[1].trim();
            let end_expr = args[2].trim();
            // Use EXTRACT(EPOCH FROM ...) / divisor approach
            let divisor = match part.to_lowercase().as_str() {
                "second" => 1,
                "minute" => 60,
                "hour" => 3600,
                "day" => 86400,
                "week" => 604800,
                _ => 1,
            };
            let replacement = if divisor == 1 {
                format!(
                    "CAST(EXTRACT(EPOCH FROM (CAST({end_expr} AS TIMESTAMP) - CAST({start_expr} AS TIMESTAMP))) AS BIGINT)"
                )
            } else {
                format!(
                    "CAST(EXTRACT(EPOCH FROM (CAST({end_expr} AS TIMESTAMP) - CAST({start_expr} AS TIMESTAMP))) / {divisor} AS BIGINT)"
                )
            };
            result = format!("{}{}{}", &result[..pos], replacement, &result[i + 1..]);
        } else {
            break;
        }
    }

    // Fix DATE_TRUNC with Null-typed second argument: wrap with TRY_CAST to TIMESTAMP.
    // This happens when seed CSV columns have all-null values (inferred as Null type).
    // DATE_TRUNC('part', col) → DATE_TRUNC('part', TRY_CAST(col AS TIMESTAMP))
    // Process from right to left to preserve string offsets.
    {
        let lower = result.to_lowercase();
        let mut positions: Vec<usize> = Vec::new();
        let mut offset = 0;
        while let Some(pos) = lower[offset..].find("date_trunc(") {
            positions.push(offset + pos);
            offset += pos + 1;
        }
        // Process in reverse order so earlier positions stay valid
        for &abs_pos in positions.iter().rev() {
            let start_args = abs_pos + "date_trunc(".len();
            let mut depth = 1;
            let mut comma_pos = None;
            let mut j = start_args;
            let bytes = result.as_bytes();
            while j < bytes.len() && depth > 0 {
                match bytes[j] {
                    b'(' => depth += 1,
                    b')' => {
                        depth -= 1;
                        if depth == 0 { break; }
                    }
                    b',' if depth == 1 && comma_pos.is_none() => comma_pos = Some(j),
                    _ => {}
                }
                j += 1;
            }
            if depth == 0 {
                if let Some(cp) = comma_pos {
                    let date_expr = result[cp + 1..j].trim();
                    if !date_expr.to_lowercase().contains("try_cast") && !date_expr.to_lowercase().contains("cast(") {
                        let new_expr = format!(" TRY_CAST({} AS TIMESTAMP)", date_expr);
                        result = format!("{}{}{}", &result[..cp + 1], new_expr, &result[j..]);
                    }
                }
            }
        }
    }

    // Fix CAST('' AS DATE) and similar empty/invalid string-to-date casts
    // that cause DataFusion optimizer simplify_expressions to fail.
    // Replace with CAST(NULL AS DATE).
    for pattern in &[
        "cast('' as date)",
        "cast(\"\" as date)",
        "cast('none' as date)",
    ] {
        while let Some(pos) = result.to_lowercase().find(pattern) {
            let end = pos + pattern.len();
            result = format!("{}CAST(NULL AS DATE){}", &result[..pos], &result[end..]);
        }
    }

    // Fix aggregate functions (SUM, AVG) on Null-typed columns.
    // When seed CSV columns have all-null values, DataFusion infers them as Null type,
    // and SUM/AVG don't support Null. Wrap arguments with TRY_CAST(... AS DOUBLE).
    for agg_fn in &["sum", "avg"] {
        let needle = format!("{agg_fn}(");
        let needle_len = needle.len();
        let lower = result.to_lowercase();
        let mut positions: Vec<usize> = Vec::new();
        let mut offset = 0;
        while let Some(pos) = lower[offset..].find(&needle) {
            let abs = offset + pos;
            // Ensure it's at a word boundary (not part of a longer identifier)
            if abs > 0 {
                let prev = result.as_bytes()[abs - 1];
                if prev.is_ascii_alphanumeric() || prev == b'_' {
                    offset = abs + 1;
                    continue;
                }
            }
            positions.push(abs);
            offset = abs + 1;
        }
        for &abs_pos in positions.iter().rev() {
            let start_args = abs_pos + needle_len;
            let mut depth = 1;
            let mut j = start_args;
            let bytes = result.as_bytes();
            while j < bytes.len() && depth > 0 {
                match bytes[j] {
                    b'(' => depth += 1,
                    b')' => {
                        depth -= 1;
                        if depth == 0 { break; }
                    }
                    _ => {}
                }
                j += 1;
            }
            if depth == 0 {
                let arg = result[start_args..j].trim();
                let arg_lower = arg.to_lowercase();
                if !arg_lower.contains("try_cast") && !arg_lower.contains("cast(") && arg != "*" {
                    let new_arg = format!("TRY_CAST({} AS DOUBLE)", arg);
                    result = format!("{}{}{}", &result[..start_args], new_arg, &result[j..]);
                }
            }
        }
    }

    // Fix Jinja list rendering: [a, b, c] → (a, b, c) in SQL IN clauses.
    // MiniJinja renders lists with [...] but SQL needs (...) for IN expressions.
    {
        let bytes = result.as_bytes();
        let mut new_result = String::with_capacity(result.len());
        let mut i = 0;
        while i < bytes.len() {
            if bytes[i] == b'[' {
                // Check if preceded by "in " or "in\n" (case insensitive)
                let prefix = &result[..i].trim_end();
                let lower_prefix = prefix.to_lowercase();
                if lower_prefix.ends_with(" in") || lower_prefix.ends_with("\nin") || lower_prefix.ends_with("\tin") {
                    // Find matching ]
                    if let Some(close) = result[i..].find(']') {
                        new_result.push('(');
                        new_result.push_str(&result[i + 1..i + close]);
                        new_result.push(')');
                        i += close + 1;
                        continue;
                    }
                }
            }
            new_result.push(bytes[i] as char);
            i += 1;
        }
        result = new_result;
    }

    result
}

/// Split a string on top-level commas (not inside parentheses).
fn split_top_level(s: &str) -> Vec<&str> {
    let mut parts = Vec::new();
    let mut depth = 0;
    let mut start = 0;
    for (i, c) in s.char_indices() {
        match c {
            '(' => depth += 1,
            ')' => depth -= 1,
            ',' if depth == 0 => {
                parts.push(&s[start..i]);
                start = i + 1;
            }
            _ => {}
        }
    }
    parts.push(&s[start..]);
    parts
}

/// Implements dbt's default `generate_schema_name` macro.
fn generate_schema_name(custom_schema: Option<&str>, default_schema: &str) -> String {
    match custom_schema {
        Some(custom) if !custom.is_empty() => format!("{}_{}", default_schema, custom),
        _ => default_schema.to_string(),
    }
}

/// Build a schema-qualified, properly quoted SQL reference: "schema"."table"
fn qualified_quoted(schema: &str, table: &str) -> String {
    format!("{}.{}", quote_ident(schema), quote_ident(table))
}

/// Executes compiled SQL against a DataFusion context (local execution).
pub struct Executor {
    ctx: SessionContext,
    target_schema: String,
}

impl Executor {
    pub fn new(target_schema: &str) -> Self {
        Self {
            ctx: SessionContext::new(),
            target_schema: target_schema.to_string(),
        }
    }

    /// Get a reference to the underlying DataFusion session context.
    pub fn session_context(&self) -> &SessionContext {
        &self.ctx
    }

    /// Register all seed CSV files as tables in the DataFusion context.
    /// This must be called BEFORE execute() so that models can reference seeds.
    ///
    /// Seeds are registered in their configured schema (via `+schema` config and
    /// `generate_schema_name`). Additionally, seeds that correspond to source tables
    /// are also registered in the source's schema so that `{{ source() }}` references
    /// resolve correctly (matching dbt's behavior where seeds back source tables in
    /// integration tests).
    pub async fn load_seeds(&self, manifest: &Manifest) -> anyhow::Result<Vec<NodeResult>> {
        let mut results = Vec::new();

        // Build a map of source table identifiers to their schemas, so we can
        // register seeds in source schemas when they match by name.
        // Also build a map of (schema, source_name) -> seed_name for aliasing.
        let mut source_schema_map: std::collections::HashMap<String, Vec<String>> =
            std::collections::HashMap::new();
        // Map from (source_schema, source_table_name) to actual identifier for cross-registration
        let mut source_name_to_id: std::collections::HashMap<(String, String), String> =
            std::collections::HashMap::new();
        for source in manifest.sources.values() {
            let table_id = source.table_identifier().to_string();
            let schema = source.schema.as_deref().unwrap_or("public").to_string();
            source_schema_map
                .entry(table_id.clone())
                .or_default()
                .push(schema.clone());
            // If identifier differs from name, record the mapping so we can also
            // register the seed under the source table name
            if source.name != table_id {
                source_name_to_id.insert((schema, source.name.clone()), table_id);
            }
        }

        for (_id, node) in &manifest.nodes {
            if let ManifestNode::Seed(seed) = node {
                let start = Instant::now();
                let csv_path = &seed.path;

                if !csv_path.exists() {
                    results.push(NodeResult {
                        unique_id: seed.unique_id.clone(),
                        name: seed.name.clone(),
                        status: NodeStatus::Error,
                        duration: start.elapsed(),
                        rows_affected: None,
                        message: Some(format!("CSV file not found: {}", csv_path.display())),
                    });
                    continue;
                }

                let schema = generate_schema_name(seed.config.schema.as_deref(), &self.target_schema);
                match self.register_csv(&seed.name, &schema, csv_path).await {
                    Ok(row_count) => {
                        tracing::info!("Loaded seed: {} ({row_count} rows)", seed.name);
                        results.push(NodeResult {
                            unique_id: seed.unique_id.clone(),
                            name: seed.name.clone(),
                            status: NodeStatus::Success,
                            duration: start.elapsed(),
                            rows_affected: Some(row_count),
                            message: None,
                        });

                        // Also register in source schemas if this seed backs a source table.
                        // This matches dbt integration test behavior where seeds populate
                        // the same tables that sources reference.
                        if let Some(source_schemas) = source_schema_map.get(&seed.name) {
                            for src_schema in source_schemas {
                                if *src_schema != schema {
                                    match self.register_csv(&seed.name, src_schema, csv_path).await {
                                        Ok(_) => {
                                            tracing::info!("Aliased seed {} into source schema {}", seed.name, src_schema);
                                        }
                                        Err(e) => {
                                            tracing::warn!(
                                                "Failed to alias seed {} into source schema {}: {}",
                                                seed.name, src_schema, e
                                            );
                                        }
                                    }
                                    // Also register under the source table name if it differs
                                    // from the identifier (seed name). This supports models that
                                    // reference by source name rather than identifier.
                                    for ((s, src_name), id) in &source_name_to_id {
                                        if s == src_schema && id == &seed.name {
                                            if let Err(e) = self.register_csv(src_name, src_schema, csv_path).await {
                                                tracing::debug!("Failed to alias seed {} as {} in {}: {}", seed.name, src_name, src_schema, e);
                                            } else {
                                                tracing::info!("Aliased seed {} as {} in {}", seed.name, src_name, src_schema);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Err(e) => {
                        results.push(NodeResult {
                            unique_id: seed.unique_id.clone(),
                            name: seed.name.clone(),
                            status: NodeStatus::Error,
                            duration: start.elapsed(),
                            rows_affected: None,
                            message: Some(e.to_string()),
                        });
                    }
                }
            }
        }

        Ok(results)
    }

    /// Create a schema in DataFusion if it doesn't already exist.
    async fn ensure_schema(&self, schema: &str) -> anyhow::Result<()> {
        let sql = format!("CREATE SCHEMA IF NOT EXISTS {}", quote_ident(schema));
        self.ctx.sql(&sql).await?.collect().await?;
        Ok(())
    }

    /// Register a CSV file as a table in a specific schema in DataFusion.
    async fn register_csv(&self, table_name: &str, schema: &str, csv_path: &Path) -> anyhow::Result<usize> {
        self.ensure_schema(schema).await?;

        // Normalize timestamps in the CSV to fix non-standard formats
        // (e.g. single-digit hours "2016-06-25 0:54:37" → "2016-06-25 00:54:37").
        let effective_path = normalize_csv_timestamps(csv_path)?;
        let csv_str = effective_path.to_str().unwrap_or_default();

        let options = CsvReadOptions::new()
            .has_header(true)
            .schema_infer_max_records(10000);
        let qualified = format!("{}.{}", schema, table_name);
        self.ctx
            .register_csv(&qualified, csv_str, options)
            .await?;

        // Lowercase all column names for dbt compatibility (dbt lowercases by default)
        let qualified_q = qualified_quoted(schema, table_name);
        let df = self.ctx.sql(&format!("SELECT * FROM {} LIMIT 0", qualified_q)).await?;
        let schema_ref = df.schema();
        let has_upper = schema_ref.fields().iter().any(|f| f.name() != &f.name().to_lowercase());
        if has_upper {
            let renames: Vec<String> = schema_ref.fields().iter().map(|f| {
                let name = f.name();
                let lower = name.to_lowercase();
                if name == &lower {
                    format!("{}", quote_ident(name))
                } else {
                    format!("{} AS {}", quote_ident(name), quote_ident(&lower))
                }
            }).collect();
            let select_sql = format!("SELECT {} FROM {}", renames.join(", "), qualified_q);
            let lowered_df = self.ctx.sql(&select_sql).await?;
            self.ctx.deregister_table(datafusion::common::TableReference::full("datafusion", schema, table_name))?;
            self.ctx.register_table(
                datafusion::common::TableReference::full("datafusion", schema, table_name),
                lowered_df.into_view(),
            )?;
        }

        // Count rows
        let qualified_q = qualified_quoted(schema, table_name);
        let df = self.ctx.sql(&format!("SELECT count(*) as cnt FROM {}", qualified_q)).await?;
        let batches = df.collect().await?;
        let row_count = if let Some(batch) = batches.first() {
            if batch.num_rows() > 0 {
                let array = batch.column(0);
                let count_array = array
                    .as_any()
                    .downcast_ref::<datafusion::arrow::array::Int64Array>();
                count_array.map(|a| a.value(0) as usize).unwrap_or(0)
            } else {
                0
            }
        } else {
            0
        };

        Ok(row_count)
    }

    /// Execute all compiled models in topological order.
    /// Execute a list of hook SQL statements (pre-hook, post-hook, on-run-start, on-run-end).
    /// Errors are logged but do not abort execution.
    pub async fn execute_hooks(&self, hooks: &[String], context: &str) {
        for hook in hooks {
            let sql = hook.trim();
            if sql.is_empty() {
                continue;
            }
            tracing::info!("{context}: {sql}");
            if let Err(e) = self.execute_query(sql).await {
                tracing::warn!("{context} failed: {e}");
            }
        }
    }

    pub async fn execute(
        &self,
        manifest: &Manifest,
        graph: &DbtGraph,
        selected: Option<&[UniqueId]>,
    ) -> anyhow::Result<ExecutionResult> {
        let order = graph.topological_sort()?;
        let mut results = Vec::new();

        for unique_id in &order {
            // Skip sources
            if manifest.sources.contains_key(unique_id) {
                continue;
            }

            // If selection provided, skip non-selected nodes
            if let Some(selected) = selected {
                if !selected.contains(unique_id) {
                    continue;
                }
            }

            let Some(node) = manifest.nodes.get(unique_id) else {
                continue;
            };

            match node {
                ManifestNode::Model(model) => {
                    // Skip disabled models
                    if model.config.enabled == Some(false) {
                        results.push(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Skipped,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("disabled".to_string()),
                        });
                        continue;
                    }

                    // Skip ephemeral models (they're CTEs, not executed directly)
                    if model.config.materialized == Materialization::Ephemeral {
                        results.push(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Skipped,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("ephemeral (CTE only)".to_string()),
                        });
                        continue;
                    }

                    let Some(compiled_sql) = &model.compiled_sql else {
                        results.push(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Error,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("No compiled SQL".to_string()),
                        });
                        continue;
                    };

                    // Skip models with empty SQL (comment-only or whitespace-only)
                    let sql_trimmed = compiled_sql
                        .lines()
                        .filter(|l| {
                            let t = l.trim();
                            !t.is_empty() && !t.starts_with("--")
                        })
                        .collect::<Vec<_>>()
                        .join("\n");
                    if sql_trimmed.trim().is_empty() {
                        results.push(NodeResult {
                            unique_id: unique_id.clone(),
                            name: model.name.clone(),
                            status: NodeStatus::Skipped,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("empty SQL (disabled model)".to_string()),
                        });
                        continue;
                    }

                    // For incremental models, check if the target table exists.
                    // If not, use the full-refresh SQL variant (compiled with is_incremental()=false)
                    // to avoid referencing {{ this }} which doesn't exist yet.
                    let effective_sql = if model.config.materialized == Materialization::Incremental {
                        let table_name = model.config.alias.as_deref().unwrap_or(&model.name);
                        let inc_schema = generate_schema_name(model.config.schema.as_deref(), &self.target_schema);
                        let inc_qualified = format!("{}.{}", inc_schema, table_name);
                        let table_exists = self.ctx.table(&inc_qualified).await.is_ok();
                        if !table_exists {
                            if let Some(fr_sql) = &model.compiled_sql_full_refresh {
                                fr_sql.clone()
                            } else {
                                compiled_sql.clone()
                            }
                        } else {
                            compiled_sql.clone()
                        }
                    } else {
                        compiled_sql.clone()
                    };

                    let start = Instant::now();

                    // Execute pre-hooks
                    if !model.config.pre_hook.is_empty() {
                        self.execute_hooks(&model.config.pre_hook, &format!("pre-hook({})", model.name)).await;
                    }

                    let result = self.execute_model(
                        &model.name,
                        &effective_sql,
                        &model.config.materialized,
                        model.config.alias.as_deref(),
                        model.config.schema.as_deref(),
                        model.config.unique_key.as_deref(),
                        model.config.incremental_strategy.as_deref(),
                    ).await;

                    // Execute post-hooks
                    if !model.config.post_hook.is_empty() {
                        self.execute_hooks(&model.config.post_hook, &format!("post-hook({})", model.name)).await;
                    }

                    match result {
                        Ok(rows) => {
                            results.push(NodeResult {
                                unique_id: unique_id.clone(),
                                name: model.name.clone(),
                                status: NodeStatus::Success,
                                duration: start.elapsed(),
                                rows_affected: Some(rows),
                                message: None,
                            });
                        }
                        Err(e) => {
                            results.push(NodeResult {
                                unique_id: unique_id.clone(),
                                name: model.name.clone(),
                                status: NodeStatus::Error,
                                duration: start.elapsed(),
                                rows_affected: None,
                                message: Some(e.to_string()),
                            });
                        }
                    }
                }
                ManifestNode::Snapshot(snapshot) => {
                    let Some(compiled_sql) = &snapshot.compiled_sql else {
                        results.push(NodeResult {
                            unique_id: unique_id.clone(),
                            name: snapshot.name.clone(),
                            status: NodeStatus::Error,
                            duration: Duration::ZERO,
                            rows_affected: None,
                            message: Some("No compiled SQL".to_string()),
                        });
                        continue;
                    };

                    let start = Instant::now();
                    let result = self.execute_snapshot(
                        &snapshot.name,
                        compiled_sql,
                        snapshot.config.alias.as_deref(),
                        snapshot.config.schema.as_deref(),
                        snapshot.config.unique_key.as_deref(),
                        snapshot.config.strategy.as_deref(),
                        snapshot.config.updated_at.as_deref(),
                        snapshot.config.check_cols.as_deref(),
                    ).await;

                    match result {
                        Ok(rows) => {
                            results.push(NodeResult {
                                unique_id: unique_id.clone(),
                                name: snapshot.name.clone(),
                                status: NodeStatus::Success,
                                duration: start.elapsed(),
                                rows_affected: Some(rows),
                                message: None,
                            });
                        }
                        Err(e) => {
                            results.push(NodeResult {
                                unique_id: unique_id.clone(),
                                name: snapshot.name.clone(),
                                status: NodeStatus::Error,
                                duration: start.elapsed(),
                                rows_affected: None,
                                message: Some(e.to_string()),
                            });
                        }
                    }
                }
                _ => {}
            }
        }

        Ok(ExecutionResult { results })
    }

    /// Execute a single model's SQL against DataFusion.
    async fn execute_model(
        &self,
        name: &str,
        sql: &str,
        materialization: &Materialization,
        alias: Option<&str>,
        custom_schema: Option<&str>,
        unique_key: Option<&str>,
        incremental_strategy: Option<&str>,
    ) -> anyhow::Result<usize> {
        let table_name = alias.unwrap_or(name);
        let schema = generate_schema_name(custom_schema, &self.target_schema);
        let qualified = format!("{}.{}", schema, table_name);
        let qualified_q = qualified_quoted(&schema, table_name);

        // Fix DataFusion compatibility: rewrite schema.table.col to alias.col
        let sql = &fix_qualified_aliases(sql);
        // Fix various SQL compatibility issues (DATE_DIFF, etc.)
        let sql = &fix_sql_compat(sql);

        self.ensure_schema(&schema).await?;

        match materialization {
            Materialization::View => {
                // Register as a view
                let df = self.ctx.sql(sql).await?;
                self.ctx
                    .register_table(&qualified, df.into_view())?;
                tracing::info!("Created view: {table_name}");
                Ok(0)
            }
            Materialization::Table => {
                // Execute and register result as a table
                let df = self.ctx.sql(sql).await?;
                let batches = df.collect().await?;
                let row_count: usize = batches.iter().map(|b| b.num_rows()).sum();

                // Create a memory table from the results
                if !batches.is_empty() {
                    let arrow_schema = batches[0].schema();
                    let table =
                        datafusion::datasource::MemTable::try_new(arrow_schema, vec![batches])?;
                    // Deregister if exists, then register
                    let _ = self.ctx.deregister_table(&qualified);
                    self.ctx.register_table(&qualified, std::sync::Arc::new(table))?;
                }
                tracing::info!("Created table: {table_name} ({row_count} rows)");
                Ok(row_count)
            }
            Materialization::Incremental => {
                // Execute the new SQL to get new batches
                let df = self.ctx.sql(sql).await?;
                let new_batches = df.collect().await?;

                if new_batches.is_empty() {
                    tracing::info!("Created incremental table: {table_name} (0 rows, no data)");
                    return Ok(0);
                }

                let new_schema = new_batches[0].schema();

                // Determine strategy: explicit > default based on unique_key
                let strategy = incremental_strategy.unwrap_or(
                    if unique_key.is_some() { "delete+insert" } else { "append" }
                );

                // Check if the old table exists
                let old_table_exists = self.ctx.table(&qualified).await.is_ok();

                let final_batches = if old_table_exists {
                    match strategy {
                        "append" => {
                            // Read old rows, concatenate with new
                            let old_df = self.ctx.table(&qualified).await?;
                            let old_batches = old_df.collect().await?;
                            let mut combined = old_batches;
                            combined.extend(new_batches);
                            combined
                        }
                        "delete+insert" | "merge" => {
                            if let Some(key) = unique_key {
                                // Register new batches as a temp table
                                let temp_name = format!("__new_{table_name}");
                                let temp_table = datafusion::datasource::MemTable::try_new(
                                    new_schema.clone(),
                                    vec![new_batches.clone()],
                                )?;
                                let _ = self.ctx.deregister_table(temp_name.as_str());
                                self.ctx.register_table(
                                    temp_name.as_str(),
                                    std::sync::Arc::new(temp_table),
                                )?;

                                // Filter old rows: keep only those whose key is NOT in new data
                                let qk = quote_ident(key);
                                let qtemp = quote_ident(&temp_name);
                                let filter_sql = format!(
                                    "SELECT * FROM {qualified_q} WHERE {qk} NOT IN (SELECT {qk} FROM {qtemp})"
                                );
                                let filtered_df = self.ctx.sql(&filter_sql).await?;
                                let filtered_old = filtered_df.collect().await?;

                                // Clean up temp table
                                let _ = self.ctx.deregister_table(temp_name.as_str());

                                // Concatenate filtered old + new
                                let mut combined = filtered_old;
                                combined.extend(new_batches);
                                combined
                            } else {
                                // No unique_key with delete+insert/merge: fall back to append
                                let old_df = self.ctx.table(&qualified).await?;
                                let old_batches = old_df.collect().await?;
                                let mut combined = old_batches;
                                combined.extend(new_batches);
                                combined
                            }
                        }
                        _ => {
                            tracing::warn!(
                                "Unknown incremental strategy '{strategy}', falling back to append"
                            );
                            let old_df = self.ctx.table(&qualified).await?;
                            let old_batches = old_df.collect().await?;
                            let mut combined = old_batches;
                            combined.extend(new_batches);
                            combined
                        }
                    }
                } else {
                    // No old table, just use new batches
                    new_batches
                };

                let row_count: usize = final_batches.iter().map(|b| b.num_rows()).sum();

                if !final_batches.is_empty() {
                    let arrow_schema = final_batches[0].schema();
                    let table = datafusion::datasource::MemTable::try_new(
                        arrow_schema,
                        vec![final_batches],
                    )?;
                    let _ = self.ctx.deregister_table(&qualified);
                    self.ctx
                        .register_table(&qualified, std::sync::Arc::new(table))?;
                }
                tracing::info!(
                    "Created incremental table: {table_name} ({row_count} rows, strategy={strategy})"
                );
                Ok(row_count)
            }
            Materialization::Ephemeral => {
                // Ephemeral models are never executed directly
                Ok(0)
            }
        }
    }

    /// Execute a snapshot with SCD Type 2 logic.
    async fn execute_snapshot(
        &self,
        name: &str,
        sql: &str,
        alias: Option<&str>,
        custom_schema: Option<&str>,
        unique_key: Option<&str>,
        strategy: Option<&str>,
        updated_at: Option<&str>,
        check_cols: Option<&[String]>,
    ) -> anyhow::Result<usize> {
        let table_name = alias.unwrap_or(name);
        let schema = generate_schema_name(custom_schema, &self.target_schema);
        let qualified = format!("{}.{}", schema, table_name);
        let qtable = qualified_quoted(&schema, table_name);
        let strategy = strategy.unwrap_or("timestamp");

        self.ensure_schema(&schema).await?;

        let unique_key = unique_key.ok_or_else(|| {
            anyhow::anyhow!("Snapshot '{name}' requires a unique_key config")
        })?;
        let quk = quote_ident(unique_key);

        // Step 1: Execute the snapshot query and register as temp table
        let temp_name = format!("__snap_new_{table_name}");
        let df = self.ctx.sql(sql).await?;
        let new_batches = df.collect().await?;

        if new_batches.is_empty() {
            tracing::info!("Snapshot {table_name}: query returned no rows");
            return Ok(0);
        }

        let new_schema = new_batches[0].schema();
        let temp_table = datafusion::datasource::MemTable::try_new(
            new_schema.clone(),
            vec![new_batches],
        )?;
        let _ = self.ctx.deregister_table(temp_name.as_str());
        self.ctx.register_table(
            temp_name.as_str(),
            std::sync::Arc::new(temp_table),
        )?;

        // Step 2: Check if target snapshot table already exists
        let table_exists = self.ctx.table(&qualified).await.is_ok();

        let final_batches = if !table_exists {
            // First run: add SCD columns to new data and register
            let col_names: Vec<String> = new_schema
                .fields()
                .iter()
                .map(|f| f.name().clone())
                .collect();
            let col_list = col_names.join(", ");

            let qtemp = quote_ident(&temp_name);
            let init_sql = format!(
                "SELECT {col_list}, \
                 CURRENT_TIMESTAMP AS dbt_valid_from, \
                 CAST(NULL AS TIMESTAMP) AS dbt_valid_to, \
                 CURRENT_TIMESTAMP AS dbt_updated_at, \
                 MD5(CAST({quk} AS VARCHAR) || CAST(CURRENT_TIMESTAMP AS VARCHAR)) AS dbt_scd_id \
                 FROM {qtemp}"
            );

            let df = self.ctx.sql(&init_sql).await?;
            let batches = df.collect().await?;
            tracing::info!("Snapshot {table_name}: initial load");
            batches
        } else {
            // Subsequent run: SCD Type 2 merge logic
            let qtemp = quote_ident(&temp_name);
            let change_condition = match strategy {
                "timestamp" => {
                    let updated_at_col = updated_at.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{name}' with timestamp strategy requires updated_at config"
                        )
                    })?;
                    let qua = quote_ident(updated_at_col);
                    format!("old_snap.{qua} != new_snap.{qua}")
                }
                "check" => {
                    let cols = check_cols.ok_or_else(|| {
                        anyhow::anyhow!(
                            "Snapshot '{name}' with check strategy requires check_cols config"
                        )
                    })?;
                    if cols.is_empty() {
                        anyhow::bail!("Snapshot '{name}': check_cols must not be empty");
                    }
                    cols.iter()
                        .map(|c| { let qc = quote_ident(c); format!("old_snap.{qc} != new_snap.{qc}") })
                        .collect::<Vec<_>>()
                        .join(" OR ")
                }
                other => {
                    anyhow::bail!("Unknown snapshot strategy: '{other}'. Use 'timestamp' or 'check'.");
                }
            };

            // Get column names from existing snapshot (excluding SCD columns)
            let existing_df = self.ctx.table(&qualified).await?;
            let existing_schema = existing_df.schema();
            let scd_columns = ["dbt_valid_from", "dbt_valid_to", "dbt_updated_at", "dbt_scd_id"];
            let source_cols: Vec<String> = existing_schema
                .fields()
                .iter()
                .map(|f| f.name().clone())
                .filter(|n| !scd_columns.contains(&n.as_str()))
                .collect();

            let old_source_cols = source_cols
                .iter()
                .map(|c| { let qc = quote_ident(c); format!("old_snap.{qc}") })
                .collect::<Vec<_>>()
                .join(", ");
            let new_source_cols = source_cols
                .iter()
                .map(|c| { let qc = quote_ident(c); format!("new_snap.{qc}") })
                .collect::<Vec<_>>()
                .join(", ");

            // Query 1: Unchanged active records + already-expired records
            let unchanged_sql = format!(
                "SELECT old_snap.* FROM {qtable} old_snap \
                 LEFT JOIN {qtemp} new_snap ON old_snap.{quk} = new_snap.{quk} \
                 WHERE old_snap.dbt_valid_to IS NOT NULL \
                 OR new_snap.{quk} IS NULL \
                 OR (old_snap.dbt_valid_to IS NULL AND NOT ({change_condition}))"
            );

            // Query 2: Expire active records that have changed
            let expire_sql = format!(
                "SELECT {old_source_cols}, \
                 old_snap.dbt_valid_from, \
                 CURRENT_TIMESTAMP AS dbt_valid_to, \
                 CURRENT_TIMESTAMP AS dbt_updated_at, \
                 old_snap.dbt_scd_id \
                 FROM {qtable} old_snap \
                 JOIN {qtemp} new_snap ON old_snap.{quk} = new_snap.{quk} \
                 WHERE old_snap.dbt_valid_to IS NULL AND ({change_condition})"
            );

            // Query 3: Insert new versions of changed records + entirely new records
            let insert_sql = format!(
                "SELECT {new_source_cols}, \
                 CURRENT_TIMESTAMP AS dbt_valid_from, \
                 CAST(NULL AS TIMESTAMP) AS dbt_valid_to, \
                 CURRENT_TIMESTAMP AS dbt_updated_at, \
                 MD5(CAST(new_snap.{quk} AS VARCHAR) || CAST(CURRENT_TIMESTAMP AS VARCHAR)) AS dbt_scd_id \
                 FROM {qtemp} new_snap \
                 LEFT JOIN {qtable} old_snap ON old_snap.{quk} = new_snap.{quk} AND old_snap.dbt_valid_to IS NULL \
                 WHERE old_snap.{quk} IS NULL OR ({change_condition})"
            );

            let merge_sql = format!(
                "{unchanged_sql} UNION ALL {expire_sql} UNION ALL {insert_sql}"
            );

            let df = self.ctx.sql(&merge_sql).await?;
            let batches = df.collect().await?;
            tracing::info!("Snapshot {table_name}: SCD Type 2 merge (strategy={strategy})");
            batches
        };

        // Clean up temp table
        let _ = self.ctx.deregister_table(format!("__snap_new_{table_name}").as_str());

        let row_count: usize = final_batches.iter().map(|b| b.num_rows()).sum();

        if !final_batches.is_empty() {
            let arrow_schema = final_batches[0].schema();
            let table = datafusion::datasource::MemTable::try_new(
                arrow_schema,
                vec![final_batches],
            )?;
            let _ = self.ctx.deregister_table(&qualified);
            self.ctx.register_table(&qualified, std::sync::Arc::new(table))?;
        }

        tracing::info!("Snapshot table: {table_name} ({row_count} rows)");
        Ok(row_count)
    }

    /// Execute an ad-hoc SQL query against the current session context.
    pub async fn execute_query(&self, sql: &str) -> anyhow::Result<Vec<datafusion::arrow::record_batch::RecordBatch>> {
        let df = self.ctx.sql(sql).await?;
        let batches = df.collect().await?;
        Ok(batches)
    }

    /// Execute generic tests defined in schema.yml and return test results.
    pub async fn execute_tests(&self, manifest: &Manifest) -> anyhow::Result<Vec<TestResult>> {
        let mut results = Vec::new();

        for (_id, node) in &manifest.nodes {
            let (model_name, model_schema, columns) = match node {
                ManifestNode::Model(m) => (&m.name, &m.config.schema, &m.columns),
                _ => continue,
            };

            let resolved_schema = generate_schema_name(model_schema.as_deref(), &self.target_schema);
            let qm = qualified_quoted(&resolved_schema, model_name);

            for col in columns {
                for test_def in &col.tests {
                    let (test_name, test_sql) = match test_def {
                        TestDef::Simple(name) => {
                            let qc = quote_ident(&col.name);
                            match name.as_str() {
                                "not_null" => (
                                    format!("not_null_{model_name}_{}", col.name),
                                    format!(
                                        "SELECT count(*) as failures FROM {qm} WHERE {qc} IS NULL"
                                    ),
                                ),
                                "unique" => (
                                    format!("unique_{model_name}_{}", col.name),
                                    format!(
                                        "SELECT {qc}, count(*) as n FROM {qm} GROUP BY {qc} HAVING count(*) > 1"
                                    ),
                                ),
                                _ => continue,
                            }
                        }
                        TestDef::Complex(map) => {
                            let qc = quote_ident(&col.name);
                            if let Some(values_val) = map.get("accepted_values") {
                                let values = extract_accepted_values(values_val);
                                if values.is_empty() {
                                    continue;
                                }
                                let values_list = values
                                    .iter()
                                    .map(|v| format!("'{}'", v.replace('\'', "''")))
                                    .collect::<Vec<_>>()
                                    .join(", ");
                                (
                                    format!("accepted_values_{model_name}_{}", col.name),
                                    format!(
                                        "SELECT {qc} FROM {qm} WHERE {qc} NOT IN ({values_list})"
                                    ),
                                )
                            } else if let Some(rel_val) = map.get("relationships") {
                                let (to_model, field) = extract_relationship(rel_val);
                                if to_model.is_empty() || field.is_empty() {
                                    continue;
                                }
                                // Look up the target model's schema for proper qualification
                                let to_schema = manifest.nodes.values()
                                    .find_map(|n| match n {
                                        ManifestNode::Model(m) if m.name == to_model => Some(m.config.schema.clone()),
                                        _ => None,
                                    })
                                    .flatten();
                                let to_resolved = generate_schema_name(to_schema.as_deref(), &self.target_schema);
                                let qt = qualified_quoted(&to_resolved, &to_model);
                                let qf = quote_ident(&field);
                                (
                                    format!("relationships_{model_name}_{}", col.name),
                                    format!(
                                        "SELECT {qc} FROM {qm} WHERE {qc} IS NOT NULL AND {qc} NOT IN (SELECT {qf} FROM {qt})"
                                    ),
                                )
                            } else {
                                continue;
                            }
                        }
                    };

                    let start = Instant::now();
                    match self.run_test_sql(&test_sql).await {
                        Ok(failure_count) => {
                            let status = if failure_count == 0 {
                                TestStatus::Pass
                            } else {
                                TestStatus::Fail
                            };
                            results.push(TestResult {
                                test_name,
                                model_name: model_name.clone(),
                                column_name: col.name.clone(),
                                status,
                                failures: failure_count,
                                duration: start.elapsed(),
                                message: None,
                            });
                        }
                        Err(e) => {
                            results.push(TestResult {
                                test_name,
                                model_name: model_name.clone(),
                                column_name: col.name.clone(),
                                status: TestStatus::Error,
                                failures: 0,
                                duration: start.elapsed(),
                                message: Some(e.to_string()),
                            });
                        }
                    }
                }
            }
        }

        // Run singular tests (ManifestNode::Test nodes with compiled SQL)
        for (_id, node) in &manifest.nodes {
            let test = match node {
                ManifestNode::Test(t) => t,
                _ => continue,
            };

            // Only run singular tests (those without test_metadata; generic tests are handled above)
            if test.test_metadata.is_some() {
                continue;
            }

            let Some(compiled_sql) = &test.compiled_sql else {
                continue;
            };

            // Derive model name from depends_on refs (first ref, if any)
            let model_name = test.depends_on.refs.first()
                .map(|r| r.model_name.clone())
                .unwrap_or_default();

            let start = Instant::now();
            match self.run_test_sql(compiled_sql).await {
                Ok(failure_count) => {
                    let status = if failure_count == 0 {
                        TestStatus::Pass
                    } else {
                        TestStatus::Fail
                    };
                    results.push(TestResult {
                        test_name: test.name.clone(),
                        model_name: model_name.clone(),
                        column_name: String::new(),
                        status,
                        failures: failure_count,
                        duration: start.elapsed(),
                        message: None,
                    });
                }
                Err(e) => {
                    results.push(TestResult {
                        test_name: test.name.clone(),
                        model_name,
                        column_name: String::new(),
                        status: TestStatus::Error,
                        failures: 0,
                        duration: start.elapsed(),
                        message: Some(e.to_string()),
                    });
                }
            }
        }

        Ok(results)
    }

    /// Run a test SQL query and return the number of failing rows.
    async fn run_test_sql(&self, sql: &str) -> anyhow::Result<usize> {
        let df = self.ctx.sql(sql).await?;
        let batches = df.collect().await?;

        // For not_null tests, the query returns count(*) as failures
        // For unique/accepted_values/relationships tests, it returns the failing rows
        if batches.is_empty() {
            return Ok(0);
        }

        // Check if the result has a "failures" column (not_null style)
        let schema = batches[0].schema();
        if schema.fields().len() == 1 && schema.field(0).name() == "failures" {
            // not_null style: single count
            let array = batches[0].column(0);
            if let Some(int_array) = array.as_any().downcast_ref::<datafusion::arrow::array::Int64Array>() {
                return Ok(int_array.value(0) as usize);
            }
        }

        // Otherwise, count all returned rows as failures
        let row_count: usize = batches.iter().map(|b| b.num_rows()).sum();
        Ok(row_count)
    }
}

/// Extract accepted_values list from a serde_yaml::Value
fn extract_accepted_values(val: &serde_yaml::Value) -> Vec<String> {
    if let Some(mapping) = val.as_mapping() {
        let key = serde_yaml::Value::String("values".to_string());
        if let Some(values) = mapping.get(&key) {
            if let Some(seq) = values.as_sequence() {
                return seq
                    .iter()
                    .filter_map(|v| v.as_str().map(String::from))
                    .collect();
            }
        }
    }
    Vec::new()
}

/// Extract relationship target model and field from a serde_yaml::Value
fn extract_relationship(val: &serde_yaml::Value) -> (String, String) {
    if let Some(mapping) = val.as_mapping() {
        let to_key = serde_yaml::Value::String("to".to_string());
        let field_key = serde_yaml::Value::String("field".to_string());

        let to_model = mapping
            .get(&to_key)
            .and_then(|v| v.as_str())
            .unwrap_or_default();
        let field = mapping
            .get(&field_key)
            .and_then(|v| v.as_str())
            .unwrap_or_default();

        // Parse ref('model_name') -> model_name
        let to_model = to_model
            .trim()
            .strip_prefix("ref('")
            .and_then(|s| s.strip_suffix("')"))
            .or_else(|| {
                to_model
                    .trim()
                    .strip_prefix("ref(\"")
                    .and_then(|s| s.strip_suffix("\")"))
            })
            .unwrap_or(to_model);

        return (to_model.to_string(), field.to_string());
    }
    (String::new(), String::new())
}

impl Default for Executor {
    fn default() -> Self {
        Self::new("public")
    }
}

/// Result of executing all models
#[derive(Debug)]
pub struct ExecutionResult {
    pub results: Vec<NodeResult>,
}

impl ExecutionResult {
    pub fn success_count(&self) -> usize {
        self.results
            .iter()
            .filter(|r| r.status == NodeStatus::Success)
            .count()
    }

    pub fn error_count(&self) -> usize {
        self.results
            .iter()
            .filter(|r| r.status == NodeStatus::Error)
            .count()
    }

    pub fn skipped_count(&self) -> usize {
        self.results
            .iter()
            .filter(|r| r.status == NodeStatus::Skipped)
            .count()
    }

    pub fn total_duration(&self) -> Duration {
        self.results.iter().map(|r| r.duration).sum()
    }
}

/// Result of executing a single node
#[derive(Debug)]
pub struct NodeResult {
    pub unique_id: UniqueId,
    pub name: String,
    pub status: NodeStatus,
    pub duration: Duration,
    pub rows_affected: Option<usize>,
    pub message: Option<String>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum NodeStatus {
    Success,
    Error,
    Skipped,
}

impl std::fmt::Display for NodeStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            NodeStatus::Success => write!(f, "SUCCESS"),
            NodeStatus::Error => write!(f, "ERROR"),
            NodeStatus::Skipped => write!(f, "SKIP"),
        }
    }
}

/// Result of running a single test
#[derive(Debug)]
pub struct TestResult {
    pub test_name: String,
    pub model_name: String,
    pub column_name: String,
    pub status: TestStatus,
    pub failures: usize,
    pub duration: Duration,
    pub message: Option<String>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum TestStatus {
    Pass,
    Fail,
    Error,
}

impl std::fmt::Display for TestStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            TestStatus::Pass => write!(f, "PASS"),
            TestStatus::Fail => write!(f, "FAIL"),
            TestStatus::Error => write!(f, "ERROR"),
        }
    }
}
