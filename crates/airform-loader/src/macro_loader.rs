use airform_core::DbtProject;
use regex::Regex;
use std::path::PathBuf;
use walkdir::WalkDir;

/// A macro definition extracted from a .sql file
#[derive(Debug, Clone)]
pub struct MacroDefinition {
    /// Name of the macro
    pub name: String,
    /// Arguments (parameter names)
    pub args: Vec<String>,
    /// The full body of the macro (between {% macro %} and {% endmacro %})
    pub body: String,
    /// Path to the file containing this macro
    pub file_path: PathBuf,
    /// Package name (None for project macros, Some("fivetran_utils") for package macros)
    pub package: Option<String>,
}

/// Discover and extract macro definitions from macro_paths and dbt_packages.
pub fn discover_macros(project: &DbtProject) -> anyhow::Result<Vec<MacroDefinition>> {
    let mut macros = Vec::new();
    let mut seen_names = std::collections::HashSet::new();

    // Scan project macro_paths first (project macros take priority)
    for macro_dir in &project.macro_paths {
        let dir = project.project_root.join(macro_dir);
        if !dir.exists() {
            tracing::debug!("Macro path does not exist: {}", dir.display());
            continue;
        }
        scan_macros_dir(&dir, &mut macros);
    }

    // Record project macro names for priority
    for m in &macros {
        seen_names.insert(m.name.clone());
    }

    // Scan dbt_packages/ for package macros
    let packages_dir = project.project_root.join(&project.packages_install_path);
    if packages_dir.exists() {
        // Each subdirectory is a package
        if let Ok(entries) = std::fs::read_dir(&packages_dir) {
            for entry in entries.filter_map(|e| e.ok()) {
                let pkg_path = entry.path();
                if !pkg_path.is_dir() {
                    continue;
                }
                let pkg_dir_name = entry.file_name().to_string_lossy().to_string();
                // Try to read the package's project name from dbt_project.yml
                let pkg_name = read_package_name(&pkg_path).unwrap_or_else(|| pkg_dir_name.clone());

                // Look for macros/ within each package
                let pkg_macros_dir = pkg_path.join("macros");
                if pkg_macros_dir.exists() {
                    let mut pkg_macros = Vec::new();
                    scan_macros_dir(&pkg_macros_dir, &mut pkg_macros);
                    // Tag and add package macros (project macros take priority)
                    for mut m in pkg_macros {
                        m.package = Some(pkg_name.clone());
                        if !seen_names.contains(&m.name) {
                            seen_names.insert(m.name.clone());
                            macros.push(m);
                        }
                    }
                }
            }
        }
        tracing::info!(
            "Discovered {} total macro definitions (including packages from {})",
            macros.len(),
            packages_dir.display()
        );
    } else {
        tracing::info!("Discovered {} macro definitions", macros.len());
    }

    Ok(macros)
}

/// Read the project name from a package's dbt_project.yml.
fn read_package_name(pkg_path: &std::path::Path) -> Option<String> {
    let yml = pkg_path.join("dbt_project.yml");
    let content = std::fs::read_to_string(&yml).ok()?;
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("name:") {
            let name = trimmed.strip_prefix("name:")?.trim().trim_matches('\'').trim_matches('"');
            if !name.is_empty() {
                return Some(name.to_string());
            }
        }
    }
    None
}

/// Scan a directory recursively for SQL macro files.
fn scan_macros_dir(dir: &std::path::Path, macros: &mut Vec<MacroDefinition>) {
    for entry in WalkDir::new(dir)
        .follow_links(true)
        .into_iter()
        .filter_map(|e| e.ok())
    {
        let path = entry.path();
        if path.extension().is_some_and(|ext| ext == "sql") {
            match std::fs::read_to_string(path) {
                Ok(contents) => {
                    let extracted = extract_macros(&contents, path);
                    macros.extend(extracted);
                }
                Err(e) => {
                    tracing::warn!("Could not read macro file {}: {}", path.display(), e);
                }
            }
        }
    }
}

/// Extract macro definitions from a SQL file.
/// Looks for `{% macro name(arg1, arg2) %}...{% endmacro %}` patterns.
fn extract_macros(contents: &str, file_path: &std::path::Path) -> Vec<MacroDefinition> {
    let mut macros = Vec::new();

    // Use regex to find the start of macro tags: {% macro name(
    // Then manually find the matching ) accounting for nested parens
    let macro_name_re =
        Regex::new(r"\{%-?\s*macro\s+(\w+)\s*\(").unwrap();

    let endmacro_re = Regex::new(r"\{%-?\s*endmacro\s*-?%\}").unwrap();
    let close_tag_re = Regex::new(r"^\s*-?%\}").unwrap();

    for cap in macro_name_re.captures_iter(contents) {
        let full_match = cap.get(0).unwrap();
        let name = cap[1].to_string();
        let args_start = full_match.end(); // position right after the opening (

        // Find matching ) accounting for nested parentheses
        let rest = &contents[args_start..];
        let mut depth: i32 = 1;
        let mut args_end_offset = 0;
        let mut in_string: Option<char> = None;
        for (i, ch) in rest.char_indices() {
            if let Some(quote) = in_string {
                if ch == '\\' {
                    continue; // skip escaped characters
                }
                if ch == quote {
                    in_string = None;
                }
            } else {
                match ch {
                    '\'' | '"' => in_string = Some(ch),
                    '(' => depth += 1,
                    ')' => {
                        depth -= 1;
                        if depth == 0 {
                            args_end_offset = i;
                            break;
                        }
                    }
                    _ => {}
                }
            }
        }

        if depth != 0 {
            tracing::warn!(
                "Unmatched parenthesis in macro '{}' in {}",
                name,
                file_path.display()
            );
            continue;
        }

        let args_str = rest[..args_end_offset].trim();
        let args = parse_macro_args(args_str);

        // Find the %} that closes the macro tag
        let after_paren = args_start + args_end_offset + 1; // skip the )
        let tag_rest = &contents[after_paren..];
        if let Some(close_match) = close_tag_re.find(tag_rest) {
            let body_start = after_paren + close_match.end();

            // Find the next {% endmacro %} after this macro's opening tag
            let body_rest = &contents[body_start..];
            if let Some(end_match) = endmacro_re.find(body_rest) {
                let body = body_rest[..end_match.start()].to_string();
                macros.push(MacroDefinition {
                    name,
                    args,
                    body,
                    file_path: file_path.to_path_buf(),
                    package: None,
                });
            } else {
                tracing::warn!(
                    "Unclosed macro '{}' in {}",
                    name,
                    file_path.display()
                );
            }
        }
    }

    macros
}

/// Parse macro arguments string, properly handling nested parentheses in default values.
/// E.g., "field_name, divide_by=100.0, divide_var=var('x',false), alias=None"
fn parse_macro_args(args_str: &str) -> Vec<String> {
    if args_str.is_empty() {
        return Vec::new();
    }
    let mut args = Vec::new();
    let mut current = String::new();
    let mut paren_depth: i32 = 0;
    let mut bracket_depth: i32 = 0;
    let mut in_string: Option<char> = None;

    for ch in args_str.chars() {
        if let Some(quote) = in_string {
            current.push(ch);
            if ch == quote {
                in_string = None;
            }
        } else {
            match ch {
                '\'' | '"' => {
                    current.push(ch);
                    in_string = Some(ch);
                }
                '(' => {
                    paren_depth += 1;
                    current.push(ch);
                }
                ')' => {
                    paren_depth -= 1;
                    current.push(ch);
                }
                '[' => {
                    bracket_depth += 1;
                    current.push(ch);
                }
                ']' => {
                    bracket_depth -= 1;
                    current.push(ch);
                }
                ',' if paren_depth == 0 && bracket_depth == 0 => {
                    let trimmed = current.trim().to_string();
                    if !trimmed.is_empty() {
                        args.push(trimmed);
                    }
                    current.clear();
                }
                _ => {
                    current.push(ch);
                }
            }
        }
    }

    let trimmed = current.trim().to_string();
    if !trimmed.is_empty() {
        args.push(trimmed);
    }

    args
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_macros() {
        let sql = r#"
{% macro generate_schema_name(custom_schema_name, node) %}
    {% if custom_schema_name %}
        {{ custom_schema_name }}
    {% else %}
        {{ target.schema }}
    {% endif %}
{% endmacro %}

{% macro cents_to_dollars(column_name, precision=2) %}
    ({{ column_name }} / 100)::numeric(16, {{ precision }})
{% endmacro %}
"#;
        let macros = extract_macros(sql, std::path::Path::new("macros/test.sql"));
        assert_eq!(macros.len(), 2);
        assert_eq!(macros[0].name, "generate_schema_name");
        assert_eq!(macros[0].args, vec!["custom_schema_name", "node"]);
        assert_eq!(macros[1].name, "cents_to_dollars");
        assert_eq!(macros[1].args, vec!["column_name", "precision=2"]);
    }
}
