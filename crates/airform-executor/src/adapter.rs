#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AdapterType {
    DataFusion,
    DuckDb,
    Snowflake,
    BigQuery,
    Databricks,
    Redshift,
    Postgres,
    MySQL,
    ClickHouse,
}

impl AdapterType {
    pub fn from_str(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "datafusion" => AdapterType::DataFusion,
            "duckdb" | "motherduck" => AdapterType::DuckDb,
            "snowflake" => AdapterType::Snowflake,
            "bigquery" => AdapterType::BigQuery,
            "databricks" => AdapterType::Databricks,
            "redshift" => AdapterType::Redshift,
            "postgres" | "postgresql" => AdapterType::Postgres,
            "mysql" => AdapterType::MySQL,
            "clickhouse" => AdapterType::ClickHouse,
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
            AdapterType::MySQL => write!(f, "mysql"),
            AdapterType::ClickHouse => write!(f, "clickhouse"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_adapter_type_from_str_new_variants() {
        assert!(matches!(AdapterType::from_str("mysql"), AdapterType::MySQL));
        assert!(matches!(AdapterType::from_str("clickhouse"), AdapterType::ClickHouse));
        assert!(matches!(AdapterType::from_str("motherduck"), AdapterType::DuckDb));
    }
}
