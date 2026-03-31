use airform_core::{AirformError, DbtProject};
use std::path::Path;

/// Load and parse dbt_project.yml from the given directory.
pub fn load_project(project_dir: &Path) -> anyhow::Result<DbtProject> {
    let project_file = project_dir.join("dbt_project.yml");
    if !project_file.exists() {
        return Err(
            AirformError::ProjectNotFound(project_dir.display().to_string()).into(),
        );
    }

    let contents = std::fs::read_to_string(&project_file)?;
    let mut project: DbtProject = serde_yaml::from_str(&contents)?;
    project.project_root = project_dir.to_path_buf();

    tracing::info!(
        "Loaded project '{}' from {}",
        project.name,
        project_file.display()
    );

    Ok(project)
}
