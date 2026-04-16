use airform_core::{
    ColumnDef, DbtProject, DependsOn, Manifest, ManifestNode, Materialization, ModelNode,
    NodeConfig, ResourceType, TestDef, TestNode,
};
use airform_jinja::{DbtContext, JinjaEngine};
use airform_loader::discover::{ModelFile, TestFile};
use airform_loader::schema::{SchemaFile, SchemaModel};
use std::collections::HashMap;

/// Parse all model SQL files into ModelNodes and add them to the manifest.
pub fn parse_models(
    project: &DbtProject,
    model_files: &[ModelFile],
    schema_files: &[SchemaFile],
    engine: &JinjaEngine,
    manifest: &mut Manifest,
) -> anyhow::Result<()> {
    for model_file in model_files {
        let raw_sql = std::fs::read_to_string(&model_file.path)?;
        let unique_id = format!("model.{}.{}", project.name, model_file.name);

        // First pass: render with execute=false to extract refs/sources/config
        let mut ctx = DbtContext::new(&project.name);
        ctx.populate_vars(&project.vars);
        let _ = engine.render(&raw_sql, &ctx);

        let refs = ctx.take_refs();
        let sources = ctx.take_sources();
        let config_from_sql = ctx.take_config();

        // Build node config: merge dbt_project.yml config -> schema.yml config -> SQL config()
        let mut config = resolve_model_config(project, model_file, schema_files);

        // Apply config() from SQL (highest priority)
        if let Some(mat) = config_from_sql.get("materialized") {
            if let Ok(m) = mat.parse::<Materialization>() {
                config.materialized = m;
            }
        }
        if let Some(schema) = config_from_sql.get("schema") {
            config.schema = Some(schema.clone());
        }
        if let Some(alias) = config_from_sql.get("alias") {
            config.alias = Some(alias.clone());
        }
        if let Some(tags) = config_from_sql.get("tags") {
            config.tags = tags.split(',').map(|s| s.trim().to_string()).collect();
        }
        if let Some(uk) = config_from_sql.get("unique_key") {
            config.unique_key = Some(uk.clone());
        }
        if let Some(hook) = config_from_sql.get("pre_hook").or_else(|| config_from_sql.get("pre-hook")) {
            config.pre_hook = vec![hook.clone()];
        }
        if let Some(hook) = config_from_sql.get("post_hook").or_else(|| config_from_sql.get("post-hook")) {
            config.post_hook = vec![hook.clone()];
        }
        if let Some(enabled) = config_from_sql.get("enabled") {
            let resolved = resolve_enabled_value(enabled, &project.vars);
            match resolved.to_lowercase().as_str() {
                "false" | "0" | "none" => config.enabled = Some(false),
                "true" | "1" => config.enabled = Some(true),
                _ => {} // complex expression we can't evaluate statically
            }
        }

        // Find schema.yml metadata for this model
        let schema_model = find_schema_model(schema_files, &model_file.name);
        let (description, columns) = if let Some(sm) = schema_model {
            (
                sm.description.clone(),
                sm.columns
                    .iter()
                    .map(|c| {
                        let tests: Vec<TestDef> = c
                            .tests
                            .iter()
                            .map(|t: &serde_yaml::Value| {
                                if let Some(s) = t.as_str() {
                                    TestDef::Simple(s.to_string())
                                } else {
                                    TestDef::Simple(format!("{t:?}"))
                                }
                            })
                            .collect();
                        ColumnDef {
                            name: c.name.clone(),
                            description: c.description.clone(),
                            data_type: c.data_type.clone(),
                            tests,
                            meta: c.meta.clone(),
                        }
                    })
                    .collect(),
            )
        } else {
            (None, Vec::new())
        };

        let depends_on = DependsOn {
            refs,
            sources,
            macros: Vec::new(),
        };

        let node = ModelNode {
            unique_id: unique_id.clone(),
            name: model_file.name.clone(),
            package_name: project.name.clone(),
            resource_type: ResourceType::Model,
            path: model_file.relative_path.clone(),
            original_file_path: model_file.path.clone(),
            raw_sql,
            compiled_sql: None,
            compiled_sql_full_refresh: None,
            config,
            depends_on,
            description,
            columns,
            tags: Vec::new(),
            extra_ctes: Vec::new(),
        };

        manifest.add_node(ManifestNode::Model(node));
    }

    tracing::info!("Parsed {} models", model_files.len());
    Ok(())
}

/// Resolve model config from dbt_project.yml hierarchy
fn resolve_model_config(
    project: &DbtProject,
    model_file: &ModelFile,
    schema_files: &[SchemaFile],
) -> NodeConfig {
    let mut config = NodeConfig::default();

    // Check dbt_project.yml models config
    if let Some(models_config) = &project.models {
        if let Some(project_models) = models_config.as_mapping() {
            // Look for project-level config under project name
            let key = serde_yaml::Value::String(project.name.clone());
            if let Some(project_config) = project_models.get(&key) {
                apply_yaml_config(&mut config, project_config);

                // Walk the path hierarchy
                if let Some(mapping) = project_config.as_mapping() {
                    let path_parts: Vec<String> = model_file
                        .relative_path
                        .parent()
                        .map(|p: &std::path::Path| {
                            p.components()
                                .filter_map(|c: std::path::Component| {
                                    c.as_os_str().to_str().map(String::from)
                                })
                                .collect()
                        })
                        .unwrap_or_default();

                    let mut current = mapping.clone();
                    for part in &path_parts {
                        let sub_key = serde_yaml::Value::String(part.to_string());
                        if let Some(sub) = current.get(&sub_key) {
                            apply_yaml_config(&mut config, sub);
                            if let Some(sub_map) = sub.as_mapping() {
                                current = sub_map.clone();
                            } else {
                                break;
                            }
                        } else {
                            break;
                        }
                    }
                }
            }
        }
    }

    // Check schema.yml config for this model
    if let Some(sm) = find_schema_model(schema_files, &model_file.name) {
        if let Some(ref schema_config) = sm.config {
            let schema_cfg: &HashMap<String, serde_yaml::Value> = schema_config;
            if let Some(serde_yaml::Value::String(mat_str)) = schema_cfg.get("materialized") {
                if let Ok(m) = mat_str.parse::<Materialization>() {
                    config.materialized = m;
                }
            }
            if let Some(serde_yaml::Value::String(schema_str)) = schema_cfg.get("schema") {
                config.schema = Some(schema_str.clone());
            }
        }
    }

    config
}

fn apply_yaml_config(config: &mut NodeConfig, value: &serde_yaml::Value) {
    if let Some(mapping) = value.as_mapping() {
        // Look for +materialized or materialized
        for key_prefix in ["", "+"] {
            let mat_key = serde_yaml::Value::String(format!("{key_prefix}materialized"));
            if let Some(mat) = mapping.get(&mat_key) {
                if let Some(s) = mat.as_str() {
                    if let Ok(m) = s.parse::<Materialization>() {
                        config.materialized = m;
                    }
                }
            }

            let schema_key = serde_yaml::Value::String(format!("{key_prefix}schema"));
            if let Some(schema) = mapping.get(&schema_key) {
                if let Some(s) = schema.as_str() {
                    config.schema = Some(s.to_string());
                }
            }

            let tags_key = serde_yaml::Value::String(format!("{key_prefix}tags"));
            if let Some(tags) = mapping.get(&tags_key) {
                if let Some(seq) = tags.as_sequence() {
                    config.tags = seq
                        .iter()
                        .filter_map(|v| v.as_str().map(String::from))
                        .collect();
                }
            }

            let enabled_key = serde_yaml::Value::String(format!("{key_prefix}enabled"));
            if let Some(enabled) = mapping.get(&enabled_key) {
                if let Some(b) = enabled.as_bool() {
                    config.enabled = Some(b);
                }
            }
        }
    }
}

fn find_schema_model<'a>(
    schema_files: &'a [SchemaFile],
    model_name: &str,
) -> Option<&'a SchemaModel> {
    for sf in schema_files {
        for m in &sf.contents.models {
            if m.name == model_name {
                return Some(m);
            }
        }
    }
    None
}

/// Resolve a config `enabled` value by evaluating simple `var(...)` calls
/// and boolean `and`/`or` expressions against the project vars.
fn resolve_enabled_value(
    val: &str,
    project_vars: &HashMap<String, serde_yaml::Value>,
) -> String {
    let trimmed = val.trim();

    // Handle `var('name', default)` pattern
    if let Some(resolved) = try_resolve_var(trimmed, project_vars) {
        return resolved;
    }

    // Handle `expr and expr` — both must be truthy
    if let Some(pos) = find_top_level_operator(trimmed, " and ") {
        let left = resolve_enabled_value(&trimmed[..pos], project_vars);
        let right = resolve_enabled_value(&trimmed[pos + 5..], project_vars);
        let l = is_truthy(&left);
        let r = is_truthy(&right);
        return if l && r { "true" } else { "false" }.to_string();
    }

    // Handle `expr or expr` — either must be truthy
    if let Some(pos) = find_top_level_operator(trimmed, " or ") {
        let left = resolve_enabled_value(&trimmed[..pos], project_vars);
        let right = resolve_enabled_value(&trimmed[pos + 4..], project_vars);
        let l = is_truthy(&left);
        let r = is_truthy(&right);
        return if l || r { "true" } else { "false" }.to_string();
    }

    trimmed.to_string()
}

/// Try to resolve a `var('name', default)` expression.
fn try_resolve_var(
    expr: &str,
    project_vars: &HashMap<String, serde_yaml::Value>,
) -> Option<String> {
    let trimmed = expr.trim();
    if !trimmed.starts_with("var(") {
        return None;
    }
    // Find the matching closing paren for var( — don't just use the last )
    let after_var = &trimmed[4..];
    let mut depth = 1;
    let mut close_pos = None;
    let mut in_string: Option<char> = None;
    for (i, ch) in after_var.char_indices() {
        if let Some(q) = in_string {
            if ch == q { in_string = None; }
        } else {
            match ch {
                '\'' | '"' => in_string = Some(ch),
                '(' => depth += 1,
                ')' => {
                    depth -= 1;
                    if depth == 0 {
                        close_pos = Some(i);
                        break;
                    }
                }
                _ => {}
            }
        }
    }
    let close = close_pos?;
    // Only match if the closing paren is the last char (i.e., this is a standalone var() call)
    if 4 + close != trimmed.len() - 1 {
        return None;
    }
    let inner = &after_var[..close];
    // Split by first comma (respecting nested parens)
    let mut depth = 0;
    let mut split_pos = None;
    for (i, ch) in inner.char_indices() {
        match ch {
            '(' => depth += 1,
            ')' => depth -= 1,
            ',' if depth == 0 => {
                split_pos = Some(i);
                break;
            }
            _ => {}
        }
    }
    let var_name = if let Some(pos) = split_pos {
        inner[..pos].trim().trim_matches('\'').trim_matches('"')
    } else {
        inner.trim().trim_matches('\'').trim_matches('"')
    };

    // Check project vars (both top-level and package-scoped)
    for (key, value) in project_vars {
        // Top-level var
        if key == var_name {
            return Some(yaml_value_to_string(value));
        }
        // Package-scoped var
        if let serde_yaml::Value::Mapping(map) = value {
            for (k, v) in map {
                if let serde_yaml::Value::String(s) = k {
                    if s == var_name {
                        return Some(yaml_value_to_string(v));
                    }
                }
            }
        }
    }

    // Var not found — use the default if provided
    if let Some(pos) = split_pos {
        let default = inner[pos + 1..].trim();
        Some(default.trim_matches('\'').trim_matches('"').to_string())
    } else {
        None
    }
}

fn yaml_value_to_string(v: &serde_yaml::Value) -> String {
    match v {
        serde_yaml::Value::Bool(b) => b.to_string(),
        serde_yaml::Value::String(s) => s.clone(),
        serde_yaml::Value::Number(n) => n.to_string(),
        _ => format!("{v:?}"),
    }
}

fn is_truthy(val: &str) -> bool {
    !matches!(val.to_lowercase().as_str(), "false" | "0" | "none" | "")
}

/// Find a top-level operator (not inside parentheses).
fn find_top_level_operator(s: &str, op: &str) -> Option<usize> {
    let mut depth = 0i32;
    let mut in_string: Option<char> = None;
    let bytes = s.as_bytes();
    let op_bytes = op.as_bytes();
    for i in 0..bytes.len() {
        if let Some(q) = in_string {
            if bytes[i] == q as u8 {
                in_string = None;
            }
        } else {
            match bytes[i] {
                b'\'' | b'"' => in_string = Some(bytes[i] as char),
                b'(' => depth += 1,
                b')' => depth -= 1,
                _ => {}
            }
            if depth == 0 && i + op_bytes.len() <= bytes.len() && &bytes[i..i + op_bytes.len()] == op_bytes {
                return Some(i);
            }
        }
    }
    None
}

/// Parse all singular test SQL files into TestNodes and add them to the manifest.
pub fn parse_singular_tests(
    project: &DbtProject,
    test_files: &[TestFile],
    engine: &JinjaEngine,
    manifest: &mut Manifest,
) -> anyhow::Result<()> {
    for test_file in test_files {
        let raw_sql = std::fs::read_to_string(&test_file.path)?;
        let unique_id = format!("test.{}.{}", project.name, test_file.name);

        // First pass: render with execute=false to extract refs/sources
        let mut ctx = DbtContext::new(&project.name);
        ctx.populate_vars(&project.vars);
        let _ = engine.render(&raw_sql, &ctx);

        let refs = ctx.take_refs();
        let sources = ctx.take_sources();

        let depends_on = DependsOn {
            refs,
            sources,
            macros: Vec::new(),
        };

        let node = TestNode {
            unique_id: unique_id.clone(),
            name: test_file.name.clone(),
            package_name: project.name.clone(),
            resource_type: ResourceType::Test,
            raw_sql,
            compiled_sql: None,
            depends_on,
            config: NodeConfig::default(),
            test_metadata: None,
        };

        manifest.add_node(ManifestNode::Test(node));
    }

    tracing::info!("Parsed {} singular tests", test_files.len());
    Ok(())
}
