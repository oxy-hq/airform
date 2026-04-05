use crate::context::dbt_type_to_arrow;
use airform_core::{Manifest, ManifestNode};
use datafusion::arrow::datatypes::SchemaRef;
use std::collections::HashMap;

/// A contract violation found during analysis.
#[derive(Debug, Clone)]
pub struct ContractViolation {
    pub model: String,
    pub kind: ViolationKind,
}

#[derive(Debug, Clone)]
pub enum ViolationKind {
    /// A column declared in the contract is missing from the inferred schema
    MissingColumn { column: String },
    /// A column in the inferred schema is not declared in the contract
    ExtraColumn { column: String },
    /// The inferred type doesn't match the declared type
    TypeMismatch {
        column: String,
        declared: String,
        inferred: String,
    },
}

impl std::fmt::Display for ContractViolation {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match &self.kind {
            ViolationKind::MissingColumn { column } => {
                write!(
                    f,
                    "{}: Missing column '{}' declared in contract",
                    self.model, column
                )
            }
            ViolationKind::ExtraColumn { column } => {
                write!(
                    f,
                    "{}: Extra column '{}' not declared in contract",
                    self.model, column
                )
            }
            ViolationKind::TypeMismatch {
                column,
                declared,
                inferred,
            } => {
                write!(
                    f,
                    "{}: Type mismatch on '{}': declared {}, inferred {}",
                    self.model, column, declared, inferred
                )
            }
        }
    }
}

/// Validate all models with enforced contracts against their inferred schemas.
pub fn validate_contracts(
    manifest: &Manifest,
    schemas: &HashMap<String, SchemaRef>,
) -> Vec<ContractViolation> {
    let mut violations = Vec::new();

    for node in manifest.nodes.values() {
        let ManifestNode::Model(model) = node else {
            continue;
        };

        // Check if contract is enforced
        let enforced = model
            .config
            .contract
            .as_ref()
            .map(|c| c.enforced)
            .unwrap_or(false);
        if !enforced {
            continue;
        }

        let table_name = model.config.alias.as_deref().unwrap_or(&model.name);

        let Some(schema) = schemas.get(table_name) else {
            continue;
        };

        // Build set of inferred column names (lowercased for case-insensitive comparison)
        let inferred_fields: HashMap<String, &datafusion::arrow::datatypes::Field> = schema
            .fields()
            .iter()
            .map(|f| (f.name().to_lowercase(), f.as_ref()))
            .collect();

        // Build set of declared column names
        let declared_names: HashMap<String, &airform_core::ColumnDef> = model
            .columns
            .iter()
            .map(|c| (c.name.to_lowercase(), c))
            .collect();

        // Check for missing columns (declared but not inferred)
        for col in &model.columns {
            let col_lower = col.name.to_lowercase();
            if !inferred_fields.contains_key(&col_lower) {
                violations.push(ContractViolation {
                    model: model.name.clone(),
                    kind: ViolationKind::MissingColumn {
                        column: col.name.clone(),
                    },
                });
            }
        }

        // Check for extra columns (inferred but not declared)
        for field in schema.fields() {
            let field_lower = field.name().to_lowercase();
            if !declared_names.contains_key(&field_lower) {
                violations.push(ContractViolation {
                    model: model.name.clone(),
                    kind: ViolationKind::ExtraColumn {
                        column: field.name().clone(),
                    },
                });
            }
        }

        // Check type mismatches for columns that exist in both
        for col in &model.columns {
            if col.data_type.is_none() {
                continue;
            }
            let col_lower = col.name.to_lowercase();
            if let Some(field) = inferred_fields.get(&col_lower) {
                let declared_arrow = dbt_type_to_arrow(col.data_type.as_deref());
                if declared_arrow != *field.data_type() {
                    violations.push(ContractViolation {
                        model: model.name.clone(),
                        kind: ViolationKind::TypeMismatch {
                            column: col.name.clone(),
                            declared: col.data_type.clone().unwrap_or_default(),
                            inferred: format!("{}", field.data_type()),
                        },
                    });
                }
            }
        }
    }

    violations
}
