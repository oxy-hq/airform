use colored::Colorize;
use std::path::Path;

pub fn run(project_dir: &Path) -> anyhow::Result<()> {
    let load_state = airform_loader::load(project_dir)?;

    for target in &load_state.project.clean_targets {
        let path = project_dir.join(target);
        if path.exists() {
            std::fs::remove_dir_all(&path)?;
            println!("  {} {}", "Cleaned".green(), path.display());
        }
    }

    println!("{}", "Done.".bold());
    Ok(())
}
