mod cache;
mod catalog;
mod context;
mod contracts;
mod dialect;
mod error;
mod lineage;

pub use cache::AnalysisCache;
pub use catalog::Catalog;
pub use context::{AnalysisResult, Analyzer};
pub use contracts::{ContractViolation, ViolationKind};
pub use dialect::SqlDialect;
pub use error::AnalyzerDiagnostic;
pub use lineage::{extract_lineage_from_plan, ColumnLineage, ColumnLineageGraph, DependencyType};
