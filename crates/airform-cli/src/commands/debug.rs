use colored::Colorize;
use std::path::Path;

pub fn run(project_dir: &Path) -> anyhow::Result<()> {
    println!("{}", "airform debug".cyan().bold());
    println!();

    let mut all_ok = true;

    // 1. Airform version
    let version = env!("CARGO_PKG_VERSION");
    println!("  {} airform version: {}", "OK".green(), version);

    // 2. Check dbt_project.yml
    let project_file = project_dir.join("dbt_project.yml");
    if project_file.exists() {
        match airform_loader::load_project(project_dir) {
            Ok(project) => {
                println!("  {} dbt_project.yml found and valid", "OK".green());
                println!("      project name: {}", project.name);
                println!(
                    "      version: {}",
                    project.version.as_deref().unwrap_or("not set")
                );
                println!(
                    "      profile: {}",
                    project.profile.as_deref().unwrap_or("not set")
                );
                println!("      model-paths: {:?}", project.model_paths);
                println!("      seed-paths: {:?}", project.seed_paths);
                println!("      target-path: {}", project.target_path);

                // 3. Check profiles.yml
                if let Some(profile_name) = &project.profile {
                    let local_profiles = project_dir.join("profiles.yml");
                    let home_profiles = dirs::home_dir()
                        .map(|h| h.join(".dbt").join("profiles.yml"))
                        .unwrap_or_default();

                    if local_profiles.exists() {
                        println!("  {} profiles.yml found at {}", "OK".green(), local_profiles.display());
                    } else if home_profiles.exists() {
                        println!("  {} profiles.yml found at {}", "OK".green(), home_profiles.display());
                    } else {
                        println!(
                            "  {} profiles.yml not found (checked {} and ~/.dbt/profiles.yml)",
                            "WARN".yellow(),
                            local_profiles.display()
                        );
                        all_ok = false;
                    }

                    // 4. Validate profile/target
                    match airform_loader::load_profile(project_dir, profile_name) {
                        Ok((profile, target)) => {
                            println!("  {} profile '{}' loaded", "OK".green(), profile_name);
                            println!("      active target: {}", profile.target);
                            println!("      adapter type: {}", target.adapter_type);
                            println!(
                                "      schema: {}",
                                target.schema.as_deref().unwrap_or("not set")
                            );
                            println!(
                                "      database: {}",
                                target.database.as_deref().unwrap_or("not set")
                            );
                        }
                        Err(e) => {
                            println!("  {} could not load profile '{}': {}", "ERROR".red(), profile_name, e);
                            all_ok = false;
                        }
                    }
                } else {
                    println!("  {} no profile configured in dbt_project.yml", "WARN".yellow());
                }

                // 5. Test basic compilation
                println!();
                println!("  Testing compilation...");
                match test_compilation(project_dir) {
                    Ok((model_count, seed_count, source_count)) => {
                        println!(
                            "  {} basic compilation succeeded ({} models, {} seeds, {} sources)",
                            "OK".green(),
                            model_count,
                            seed_count,
                            source_count,
                        );
                    }
                    Err(e) => {
                        println!("  {} compilation failed: {}", "ERROR".red(), e);
                        all_ok = false;
                    }
                }
            }
            Err(e) => {
                println!(
                    "  {} dbt_project.yml found but invalid: {}",
                    "ERROR".red(),
                    e
                );
                all_ok = false;
            }
        }
    } else {
        println!(
            "  {} dbt_project.yml not found at {}",
            "ERROR".red(),
            project_file.display()
        );
        all_ok = false;
    }

    println!();
    if all_ok {
        println!("{}", "All checks passed!".green().bold());
    } else {
        println!(
            "{}",
            "Some checks failed. See above for details.".yellow().bold()
        );
    }

    Ok(())
}

fn test_compilation(project_dir: &Path) -> anyhow::Result<(usize, usize, usize)> {
    let load_state = airform_loader::load(project_dir)?;
    let engine = airform_jinja::JinjaEngine::new();
    let manifest = airform_parser::parse(&load_state, &engine)?;

    let model_count = manifest.models().count();
    let seed_count = manifest
        .nodes
        .values()
        .filter(|n| matches!(n, airform_core::ManifestNode::Seed(_)))
        .count();
    let source_count = manifest.sources.len();

    Ok((model_count, seed_count, source_count))
}
