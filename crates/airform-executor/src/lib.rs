mod executor;
mod adapter;
pub mod adapters;
pub mod csv;
pub mod info_schema;
pub mod warehouse;

pub use executor::{ExecutionResult, Executor, NodeResult, NodeStatus, TestResult, TestStatus};
pub use adapter::AdapterType;
pub use warehouse::{QueryResult, WarehouseAdapter};
pub use info_schema::register_info_schema;
pub use adapters::{
    BigQueryAdapter, ClickHouseAdapter, DataFusionAdapter, DuckDbAdapter,
    MySqlAdapter, PostgresAdapter, SnowflakeAdapter,
};
