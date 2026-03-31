/// Database adapter type
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AdapterType {
    /// Local DataFusion execution (no warehouse needed)
    DataFusion,
    /// DuckDB local execution
    DuckDb,
    /// Remote adapters (not yet implemented)
    Snowflake,
    BigQuery,
    Databricks,
    Redshift,
    Postgres,
}

impl AdapterType {
    pub fn from_str(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "datafusion" => AdapterType::DataFusion,
            "duckdb" => AdapterType::DuckDb,
            "snowflake" => AdapterType::Snowflake,
            "bigquery" => AdapterType::BigQuery,
            "databricks" => AdapterType::Databricks,
            "redshift" => AdapterType::Redshift,
            "postgres" | "postgresql" => AdapterType::Postgres,
            _ => AdapterType::DataFusion,
        }
    }

    pub fn is_local(&self) -> bool {
        matches!(self, AdapterType::DataFusion | AdapterType::DuckDb)
    }
}

impl std::fmt::Display for AdapterType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AdapterType::DataFusion => write!(f, "datafusion"),
            AdapterType::DuckDb => write!(f, "duckdb"),
            AdapterType::Snowflake => write!(f, "snowflake"),
            AdapterType::BigQuery => write!(f, "bigquery"),
            AdapterType::Databricks => write!(f, "databricks"),
            AdapterType::Redshift => write!(f, "redshift"),
            AdapterType::Postgres => write!(f, "postgres"),
        }
    }
}
