use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::{Path, PathBuf};

/// Cache file storing SHA256 hashes of SQL files for incremental rebuilds.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct FileCache {
    /// Map of relative file path -> SHA256 hash
    pub hashes: HashMap<String, String>,
}

impl FileCache {
    /// Load cache from the target directory.
    pub fn load(target_dir: &Path) -> Self {
        let cache_path = Self::cache_path(target_dir);
        if cache_path.exists() {
            match std::fs::read_to_string(&cache_path) {
                Ok(contents) => match serde_json::from_str(&contents) {
                    Ok(cache) => return cache,
                    Err(e) => {
                        tracing::debug!("Could not parse cache file: {e}");
                    }
                },
                Err(e) => {
                    tracing::debug!("Could not read cache file: {e}");
                }
            }
        }
        Self::default()
    }

    /// Save cache to the target directory.
    pub fn save(&self, target_dir: &Path) -> anyhow::Result<()> {
        std::fs::create_dir_all(target_dir)?;
        let cache_path = Self::cache_path(target_dir);
        let json = serde_json::to_string_pretty(self)?;
        std::fs::write(&cache_path, json)?;
        Ok(())
    }

    /// Compute SHA256 hash of a file's contents.
    pub fn compute_hash(contents: &str) -> String {
        use std::collections::hash_map::DefaultHasher;
        use std::hash::{Hash, Hasher};

        // Use a simple hash for now (not cryptographic SHA256 to avoid extra deps).
        // This is sufficient for change detection.
        let mut hasher = DefaultHasher::new();
        contents.hash(&mut hasher);
        format!("{:016x}", hasher.finish())
    }

    /// Check if a file has changed since the last cache.
    /// Returns true if the file needs recompilation.
    pub fn is_changed(&self, file_key: &str, current_contents: &str) -> bool {
        let current_hash = Self::compute_hash(current_contents);
        match self.hashes.get(file_key) {
            Some(cached_hash) => *cached_hash != current_hash,
            None => true, // New file, needs compilation
        }
    }

    /// Update the hash for a file.
    pub fn update(&mut self, file_key: &str, contents: &str) {
        let hash = Self::compute_hash(contents);
        self.hashes.insert(file_key.to_string(), hash);
    }

    fn cache_path(target_dir: &Path) -> PathBuf {
        target_dir.join(".airform_cache.json")
    }
}
