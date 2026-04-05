mod project;
mod profile;
pub mod schema;
pub mod discover;
pub mod macro_loader;

pub use project::load_project;
pub use profile::load_profile;
pub use schema::load_schema_files;
pub use discover::{discover_models, discover_seeds, discover_snapshots};
pub use macro_loader::{discover_macros, MacroDefinition};

use airform_core::{DbtProject, DbtProfile, DbtTarget};
use std::path::Path;

/// Fully loaded project state -- the output of the "load" phase.
#[derive(Debug, Clone)]
pub struct LoadState {
    pub project: DbtProject,
    pub profile: Option<DbtProfile>,
    pub target: Option<DbtTarget>,
    pub model_files: Vec<discover::ModelFile>,
    pub seed_files: Vec<discover::SeedFile>,
    pub snapshot_files: Vec<discover::SnapshotFile>,
    pub schema_files: Vec<schema::SchemaFile>,
    pub macro_definitions: Vec<MacroDefinition>,
}

/// Load everything needed to start parsing.
pub fn load(project_dir: &Path) -> anyhow::Result<LoadState> {
    load_with_target(project_dir, None)
}

/// Load everything with an optional target override.
pub fn load_with_target(project_dir: &Path, target_override: Option<&str>) -> anyhow::Result<LoadState> {
    let project = load_project(project_dir)?;
    let (profile, target) = match &project.profile {
        Some(profile_name) => {
            match load_profile(project_dir, profile_name) {
                Ok((p, default_target)) => {
                    if let Some(target_name) = target_override {
                        // Try to find the target in profile outputs
                        if let Some(t) = p.outputs.get(target_name) {
                            tracing::info!("Using target override: {target_name}");
                            (Some(p.clone()), Some(t.clone()))
                        } else {
                            // Check environments for a target mapping
                            let env_target = project
                                .environments
                                .iter()
                                .find(|e| e.name == target_name)
                                .and_then(|e| e.target.as_deref())
                                .and_then(|t| p.outputs.get(t).cloned());
                            match env_target {
                                Some(t) => (Some(p), Some(t)),
                                None => {
                                    anyhow::bail!(
                                        "Target '{target_name}' not found in profile '{profile_name}'"
                                    );
                                }
                            }
                        }
                    } else {
                        (Some(p), Some(default_target))
                    }
                }
                Err(e) => {
                    tracing::warn!("Could not load profile: {e}. Continuing without profile.");
                    (None, None)
                }
            }
        }
        None => (None, None),
    };

    let model_files = discover_models(&project)?;
    let seed_files = discover_seeds(&project)?;
    let snapshot_files = discover_snapshots(&project)?;
    let schema_files = load_schema_files(&project)?;
    let macro_definitions = discover_macros(&project)?;

    Ok(LoadState {
        project,
        profile,
        target,
        model_files,
        seed_files,
        snapshot_files,
        schema_files,
        macro_definitions,
    })
}
