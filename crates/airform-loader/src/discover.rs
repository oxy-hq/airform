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

/// A discovered snapshot file on disk
#[derive(Debug, Clone)]
pub struct SnapshotFile {
    /// Absolute path to the SQL file
    pub path: PathBuf,
    /// Path relative to the snapshot directory
    pub relative_path: PathBuf,
    /// Snapshot name (filename without extension)
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

/// Walk model directories and discover all .sql model files.
/// When multiple files share the same model name (e.g. target-specific variants
/// like bigquery/, snowflake/, databricks/ alongside default/), we keep only one
/// per name — preferring the one under a `default/` directory.
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

    // Sort files by path for deterministic dedup ordering across platforms.
    files.sort_by(|a, b| a.relative_path.cmp(&b.relative_path));

    // Deduplicate models with the same name: prefer `default/` variant over
    // target-specific variants (bigquery/, snowflake/, databricks/, spark/).
    let total_before_dedup = files.len();
    let mut seen: std::collections::HashMap<String, usize> = std::collections::HashMap::new();
    let mut deduped: Vec<ModelFile> = Vec::with_capacity(files.len());
    for file in files {
        let rel_str = file.relative_path.to_string_lossy();
        let is_default = rel_str.contains("/default/") || rel_str.starts_with("default/");
        if let Some(&existing_idx) = seen.get(&file.name) {
            let existing_rel = deduped[existing_idx].relative_path.to_string_lossy().to_string();
            let existing_is_default = existing_rel.contains("/default/") || existing_rel.starts_with("default/");
            // Replace if current is default and existing is not
            if is_default && !existing_is_default {
                tracing::debug!(
                    "Dedup model '{}': preferring {} over {}",
                    file.name, rel_str, existing_rel
                );
                deduped[existing_idx] = file;
            } else {
                tracing::debug!(
                    "Dedup model '{}': keeping {} over {}",
                    file.name, existing_rel, rel_str
                );
            }
        } else {
            seen.insert(file.name.clone(), deduped.len());
            deduped.push(file);
        }
    }

    tracing::info!("Discovered {} model files ({} after dedup)", total_before_dedup, deduped.len());
    Ok(deduped)
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

/// Walk snapshot directories and discover all .sql snapshot files
pub fn discover_snapshots(project: &DbtProject) -> anyhow::Result<Vec<SnapshotFile>> {
    let mut files = Vec::new();

    for snapshot_dir in &project.snapshot_paths {
        let dir = project.project_root.join(snapshot_dir);
        if !dir.exists() {
            tracing::debug!("Snapshot path does not exist: {}", dir.display());
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

                files.push(SnapshotFile {
                    path: path.to_path_buf(),
                    relative_path,
                    name,
                });
            }
        }
    }

    tracing::info!("Discovered {} snapshot files", files.len());
    Ok(files)
}
