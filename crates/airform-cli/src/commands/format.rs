use colored::Colorize;
use regex::Regex;
use std::path::Path;

/// SQL keywords to uppercase
const SQL_KEYWORDS: &[&str] = &[
    "SELECT", "FROM", "WHERE", "JOIN", "LEFT", "RIGHT", "INNER", "OUTER", "FULL", "CROSS",
    "ON", "AND", "OR", "NOT", "IN", "EXISTS", "BETWEEN", "LIKE", "IS", "NULL", "AS",
    "GROUP", "BY", "ORDER", "HAVING", "LIMIT", "OFFSET", "UNION", "ALL", "DISTINCT",
    "INSERT", "INTO", "UPDATE", "DELETE", "CREATE", "DROP", "ALTER", "TABLE", "VIEW",
    "INDEX", "SET", "VALUES", "CASE", "WHEN", "THEN", "ELSE", "END", "WITH", "RECURSIVE",
    "OVER", "PARTITION", "ROWS", "RANGE", "UNBOUNDED", "PRECEDING", "FOLLOWING", "CURRENT",
    "ROW", "ASC", "DESC", "NULLS", "FIRST", "LAST", "TRUE", "FALSE", "CAST", "COALESCE",
    "IF", "EXCEPT", "INTERSECT", "LATERAL", "NATURAL", "USING", "WINDOW", "FILTER",
    "WITHIN", "FETCH", "NEXT", "ONLY", "FOR", "MATERIALIZED",
];

pub fn run(project_dir: &Path, check: bool) -> anyhow::Result<()> {
    let load_state = airform_loader::load(project_dir)?;

    let mut files_changed = 0;
    let mut files_checked = 0;

    for model_file in &load_state.model_files {
        let original = std::fs::read_to_string(&model_file.path)?;
        let formatted = format_sql(&original);
        files_checked += 1;

        if formatted != original {
            files_changed += 1;
            if check {
                println!(
                    "  {} {}",
                    "would reformat".yellow(),
                    model_file.path.display()
                );
            } else {
                std::fs::write(&model_file.path, &formatted)?;
                println!(
                    "  {} {}",
                    "reformatted".green(),
                    model_file.path.display()
                );
            }
        }
    }

    println!();
    if check {
        if files_changed > 0 {
            println!(
                "{}",
                format!(
                    "{files_changed} file(s) would be reformatted ({files_checked} checked)"
                )
                .yellow()
                .bold()
            );
            std::process::exit(1);
        } else {
            println!(
                "{}",
                format!("All {files_checked} file(s) are properly formatted")
                    .green()
                    .bold()
            );
        }
    } else {
        println!(
            "{}",
            format!("{files_changed} file(s) reformatted ({files_checked} checked)")
                .green()
                .bold()
        );
    }

    Ok(())
}

/// Apply basic SQL formatting:
/// - Uppercase SQL keywords
/// - Consistent indentation (4 spaces)
/// - Normalize whitespace around commas
fn format_sql(sql: &str) -> String {
    let mut result = String::new();

    for line in sql.lines() {
        let formatted_line = format_line(line);
        result.push_str(&formatted_line);
        result.push('\n');
    }

    // Remove trailing newlines but keep one
    let trimmed = result.trim_end();
    format!("{trimmed}\n")
}

fn format_line(line: &str) -> String {
    // Preserve empty lines
    if line.trim().is_empty() {
        return String::new();
    }

    // Detect leading whitespace
    let leading_spaces = line.len() - line.trim_start().len();
    let indent = &line[..leading_spaces];

    let content = line.trim_start();

    // Don't format Jinja blocks or comments
    if content.starts_with("{%")
        || content.starts_with("{{")
        || content.starts_with("{#")
        || content.starts_with("--")
        || content.starts_with("/*")
    {
        return line.to_string();
    }

    // Uppercase SQL keywords (word boundary matching)
    let mut formatted = content.to_string();
    for keyword in SQL_KEYWORDS {
        let pattern = format!(r"(?i)\b{}\b", regex::escape(keyword));
        let re = Regex::new(&pattern).unwrap();
        formatted = re.replace_all(&formatted, *keyword).to_string();
    }

    // Normalize spaces around commas (no space before, one space after)
    let comma_re = Regex::new(r"\s*,\s*").unwrap();
    formatted = comma_re.replace_all(&formatted, ", ").to_string();

    format!("{indent}{formatted}")
}
