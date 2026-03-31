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
}

/// Discover and extract macro definitions from macro_paths.
pub fn discover_macros(project: &DbtProject) -> anyhow::Result<Vec<MacroDefinition>> {
    let mut macros = Vec::new();

    for macro_dir in &project.macro_paths {
        let dir = project.project_root.join(macro_dir);
        if !dir.exists() {
            tracing::debug!("Macro path does not exist: {}", dir.display());
            continue;
        }

        for entry in WalkDir::new(&dir)
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

    tracing::info!("Discovered {} macro definitions", macros.len());
    Ok(macros)
}

/// Extract macro definitions from a SQL file.
/// Looks for `{% macro name(arg1, arg2) %}...{% endmacro %}` patterns.
fn extract_macros(contents: &str, file_path: &std::path::Path) -> Vec<MacroDefinition> {
    let mut macros = Vec::new();

    // Pattern: {% macro name(args) %} ... {% endmacro %}
    // Use a regex to find the macro opening tags, then find the matching endmacro
    let macro_start_re =
        Regex::new(r"\{%-?\s*macro\s+(\w+)\s*\(([^)]*)\)\s*-?%\}").unwrap();

    let endmacro_re = Regex::new(r"\{%-?\s*endmacro\s*-?%\}").unwrap();

    let starts: Vec<(usize, usize, String, Vec<String>)> = macro_start_re
        .captures_iter(contents)
        .map(|cap| {
            let full_match = cap.get(0).unwrap();
            let name = cap[1].to_string();
            let args_str = cap[2].trim();
            let args: Vec<String> = if args_str.is_empty() {
                Vec::new()
            } else {
                args_str
                    .split(',')
                    .map(|a| {
                        // Handle default values: arg=default
                        let a = a.trim();
                        if let Some((name, _)) = a.split_once('=') {
                            name.trim().to_string()
                        } else {
                            a.to_string()
                        }
                    })
                    .collect()
            };
            (full_match.start(), full_match.end(), name, args)
        })
        .collect();

    for (_start, body_start, name, args) in starts {
        // Find the next {% endmacro %} after this macro's opening tag
        let rest = &contents[body_start..];
        if let Some(end_match) = endmacro_re.find(rest) {
            let body = rest[..end_match.start()].to_string();
            macros.push(MacroDefinition {
                name,
                args,
                body,
                file_path: file_path.to_path_buf(),
            });
        } else {
            tracing::warn!(
                "Unclosed macro '{}' in {}",
                name,
                file_path.display()
            );
        }
    }

    macros
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
        assert_eq!(macros[1].args, vec!["column_name", "precision"]);
    }
}
