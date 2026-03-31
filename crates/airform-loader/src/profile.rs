use airform_core::{AirformError, DbtProfile, DbtProfiles, DbtTarget};
use std::path::Path;

/// Load a specific profile and its active target from profiles.yml.
/// Searches: project_dir/profiles.yml, then ~/.dbt/profiles.yml
pub fn load_profile(
    project_dir: &Path,
    profile_name: &str,
) -> anyhow::Result<(DbtProfile, DbtTarget)> {
    let profiles = load_profiles_file(project_dir)?;

    let profile = profiles
        .profiles
        .get(profile_name)
        .ok_or_else(|| AirformError::ProfileNotFound(profile_name.to_string()))?
        .clone();

    let target = profile
        .outputs
        .get(&profile.target)
        .ok_or_else(|| {
            AirformError::TargetNotFound(profile.target.clone(), profile_name.to_string())
        })?
        .clone();

    tracing::info!(
        "Using profile '{}', target '{}' (type: {})",
        profile_name,
        profile.target,
        target.adapter_type
    );

    Ok((profile, target))
}

fn load_profiles_file(project_dir: &Path) -> anyhow::Result<DbtProfiles> {
    // Try project-local first
    let local_path = project_dir.join("profiles.yml");
    if local_path.exists() {
        let contents = std::fs::read_to_string(&local_path)?;
        return Ok(serde_yaml::from_str(&contents)?);
    }

    // Try ~/.dbt/profiles.yml
    if let Some(home) = dirs::home_dir() {
        let global_path = home.join(".dbt").join("profiles.yml");
        if global_path.exists() {
            let contents = std::fs::read_to_string(&global_path)?;
            return Ok(serde_yaml::from_str(&contents)?);
        }
    }

    Err(anyhow::anyhow!(
        "profiles.yml not found in {} or ~/.dbt/",
        project_dir.display()
    ))
}
