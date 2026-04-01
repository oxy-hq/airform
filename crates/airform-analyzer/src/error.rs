use std::fmt;

/// A non-fatal diagnostic emitted during SQL analysis.
#[derive(Debug, Clone)]
pub enum AnalyzerDiagnostic {
    /// SQL could not be parsed or planned
    SqlError {
        model: String,
        message: String,
    },
    /// A dependency's schema is not available (no column defs, no CSV, etc.)
    SchemaUnavailable {
        node: String,
    },
}

impl fmt::Display for AnalyzerDiagnostic {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AnalyzerDiagnostic::SqlError { model, message } => {
                write!(f, "SQL error in model '{model}': {message}")
            }
            AnalyzerDiagnostic::SchemaUnavailable { node } => {
                write!(f, "Schema unavailable for '{node}' -- skipping validation")
            }
        }
    }
}
