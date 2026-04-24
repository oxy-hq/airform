pub mod bigquery;
pub mod clickhouse;
pub mod datafusion;
pub mod duckdb;
pub mod mysql;
pub mod postgres;
pub mod snowflake;

pub use self::bigquery::BigQueryAdapter;
pub use self::clickhouse::ClickHouseAdapter;
pub use self::datafusion::DataFusionAdapter;
pub use self::duckdb::DuckDbAdapter;
pub use self::mysql::MySqlAdapter;
pub use self::postgres::PostgresAdapter;
pub use self::snowflake::SnowflakeAdapter;

use crate::adapter::AdapterType;
use crate::warehouse::WarehouseAdapter;

pub async fn create_adapter(
    adapter_type: &AdapterType,
    target: Option<&airform_core::DbtTarget>,
) -> anyhow::Result<Box<dyn WarehouseAdapter>> {
    match adapter_type {
        AdapterType::Snowflake => {
            let adapter = if let Some(t) = target { SnowflakeAdapter::from_target(t).await? } else { SnowflakeAdapter::from_env().await? };
            Ok(Box::new(adapter))
        }
        AdapterType::BigQuery => {
            let adapter = if let Some(t) = target { BigQueryAdapter::from_target(t)? } else { BigQueryAdapter::from_env()? };
            Ok(Box::new(adapter))
        }
        AdapterType::DuckDb => {
            let adapter = if let Some(t) = target { DuckDbAdapter::from_target(t)? } else { DuckDbAdapter::in_memory()? };
            Ok(Box::new(adapter))
        }
        AdapterType::Postgres | AdapterType::Redshift => {
            let adapter = if let Some(t) = target { PostgresAdapter::from_target(t).await? } else { PostgresAdapter::from_env().await? };
            Ok(Box::new(adapter))
        }
        AdapterType::MySQL => {
            let adapter = if let Some(t) = target { MySqlAdapter::from_target(t)? } else { MySqlAdapter::from_env()? };
            Ok(Box::new(adapter))
        }
        AdapterType::ClickHouse => {
            let adapter = if let Some(t) = target { ClickHouseAdapter::from_target(t)? } else { ClickHouseAdapter::from_env()? };
            Ok(Box::new(adapter))
        }
        _ => Ok(Box::new(DataFusionAdapter::new())),
    }
}
