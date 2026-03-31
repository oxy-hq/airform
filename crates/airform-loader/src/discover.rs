use airform_core::DbtProject;
use std::path::PathBuf;
use walkdir::WalkDir;

/// A discovered model file on disk
#[derive(Debug, Clone)]
pub struct ModelFile {
    /// Absolute path to the SQL file
    pub path: PathBuf,
    /// Path relative to the model directory (e.g., staging/stg_orders.sql)
    pub relative_path: PathBuf,
    /// Model name (filename without extension)
    pub name: String,
}

/// A discovered seed (CSV) file on disk
#[derive(Debug, Clone)]
pub struct SeedFile {
    /// Absolute path to the CSV file
    pub path: PathBuf,
    /// Path relative to the seed directory
    pub relative_path: PathBuf,
    /// Seed name (filename without extension)
    pub name: String,
}

/// Walk model directories and discover all .sql model files
pub fn discover_models(project: &DbtProject) -> anyhow::Result<Vec<ModelFile>> {
    let mut files = Vec::new();

    for model_dir in &project.model_paths {
        let dir = project.project_root.join(model_dir);
        if !dir.exists() {
            tracing::debug!("Model path does not exist: {}", dir.display());
            continue;
        }

        for entry in WalkDir::new(&dir)
            .follow_links(true)
            .into_iter()
            .filter_map(|e| e.ok())
        {
            let path = entry.path();
            if path.extension().is_some_and(|ext| ext == "sql") {
                let relative_path = path.strip_prefix(&dir).unwrap_or(path).to_path_buf();
                let name = path
                    .file_stem()
                    .unwrap_or_default()
                    .to_string_lossy()
                    .to_string();

                files.push(ModelFile {
                    path: path.to_path_buf(),
                    relative_path,
                    name,
                });
            }
        }
    }

    tracing::info!("Discovered {} model files", files.len());
    Ok(files)
}

/// Walk seed directories and discover all .csv seed files
pub fn discover_seeds(project: &DbtProject) -> anyhow::Result<Vec<SeedFile>> {
    let mut files = Vec::new();

    for seed_dir in &project.seed_paths {
        let dir = project.project_root.join(seed_dir);
        if !dir.exists() {
            tracing::debug!("Seed path does not exist: {}", dir.display());
            continue;
        }

        for entry in WalkDir::new(&dir)
            .follow_links(true)
            .into_iter()
            .filter_map(|e| e.ok())
        {
            let path = entry.path();
            if path.extension().is_some_and(|ext| ext == "csv") {
                let relative_path = path.strip_prefix(&dir).unwrap_or(path).to_path_buf();
                let name = path
                    .file_stem()
                    .unwrap_or_default()
                    .to_string_lossy()
                    .to_string();

                files.push(SeedFile {
                    path: path.to_path_buf(),
                    relative_path,
                    name,
                });
            }
        }
    }

    tracing::info!("Discovered {} seed files", files.len());
    Ok(files)
}
