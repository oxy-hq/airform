pub mod bigquery;
pub mod datafusion;
pub mod snowflake;

pub use self::bigquery::BigQueryAdapter;
pub use self::datafusion::DataFusionAdapter;
pub use self::snowflake::SnowflakeAdapter;

use crate::adapter::AdapterType;
use crate::warehouse::WarehouseAdapter;

/// Create a WarehouseAdapter from an AdapterType and optional target config.
pub fn create_adapter(
    adapter_type: &AdapterType,
    target: Option<&airform_core::DbtTarget>,
) -> anyhow::Result<Box<dyn WarehouseAdapter>> {
    match adapter_type {
        AdapterType::Snowflake => {
            let adapter = if let Some(t) = target {
                SnowflakeAdapter::from_target(t)?
            } else {
                SnowflakeAdapter::from_env()?
            };
            Ok(Box::new(adapter))
        }
        AdapterType::BigQuery => {
            let adapter = if let Some(t) = target {
                BigQueryAdapter::from_target(t)?
            } else {
                BigQueryAdapter::from_env()?
            };
            Ok(Box::new(adapter))
        }
        _ => Ok(Box::new(DataFusionAdapter::new())),
    }
}
