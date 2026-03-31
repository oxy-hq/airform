use thiserror::Error;

#[derive(Error, Debug)]
pub enum AirformError {
    #[error("Project not found: no dbt_project.yml in {0}")]
    ProjectNotFound(String),

    #[error("Profile '{0}' not found in profiles.yml")]
    ProfileNotFound(String),

    #[error("Target '{0}' not found in profile '{1}'")]
    TargetNotFound(String, String),

    #[error("Model '{0}' not found")]
    ModelNotFound(String),

    #[error("Source '{source_name}.{table_name}' not found")]
    SourceNotFound {
        source_name: String,
        table_name: String,
    },

    #[error("Circular dependency detected: {0}")]
    CircularDependency(String),

    #[error("Compilation error in {node}: {message}")]
    CompilationError { node: String, message: String },

    #[error("Jinja render error in {node}: {message}")]
    JinjaError { node: String, message: String },

    #[error("Execution error in {node}: {message}")]
    ExecutionError { node: String, message: String },

    #[error("YAML parse error: {0}")]
    YamlError(#[from] serde_yaml::Error),

    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),

    #[error("{0}")]
    Other(String),
}

pub type AirformResult<T> = Result<T, AirformError>;
