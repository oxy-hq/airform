use std::path::Path;

/// Initialize a new dbt project scaffold
pub fn run(project_dir: &Path, name: &str) -> anyhow::Result<()> {
    let target = project_dir.join(name);

    if target.exists() {
        anyhow::bail!("Directory '{}' already exists", target.display());
    }

    std::fs::create_dir_all(target.join("models/staging"))?;
    std::fs::create_dir_all(target.join("models/marts"))?;
    std::fs::create_dir_all(target.join("seeds"))?;
    std::fs::create_dir_all(target.join("tests"))?;
    std::fs::create_dir_all(target.join("macros"))?;
    std::fs::create_dir_all(target.join("snapshots"))?;
    std::fs::create_dir_all(target.join("analyses"))?;

    // Write dbt_project.yml
    let project_yml = format!(
        r#"name: '{name}'
version: '1.0.0'
config-version: 2

profile: '{name}'

model-paths: ["models"]
seed-paths: ["seeds"]
test-paths: ["tests"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
analysis-paths: ["analyses"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  {name}:
    +materialized: view
    staging:
      +materialized: view
    marts:
      +materialized: table
"#
    );
    std::fs::write(target.join("dbt_project.yml"), project_yml)?;

    // Write profiles.yml (local DataFusion)
    let profiles_yml = format!(
        r#"{name}:
  target: dev
  outputs:
    dev:
      type: datafusion
      schema: main
      threads: 4
"#
    );
    std::fs::write(target.join("profiles.yml"), profiles_yml)?;

    // Write a sample model
    let sample_model = r#"-- This is a sample model
-- Replace this with your own SQL

select
    1 as id,
    'hello airform' as message
"#;
    std::fs::write(target.join("models/staging/stg_sample.sql"), sample_model)?;

    // Write sample schema.yml
    let schema_yml = format!(
        r#"version: 2

models:
  - name: stg_sample
    description: "A sample staging model"
    columns:
      - name: id
        description: "Primary key"
        tests:
          - unique
          - not_null
      - name: message
        description: "A greeting"
"#
    );
    std::fs::write(target.join("models/staging/_schema.yml"), schema_yml)?;

    // Write .gitignore
    let gitignore = "target/\ndbt_packages/\nlogs/\n";
    std::fs::write(target.join(".gitignore"), gitignore)?;

    println!("Project '{name}' initialized at {}", target.display());
    println!();
    println!("Next steps:");
    println!("  cd {name}");
    println!("  airform parse      # Validate project");
    println!("  airform compile    # Compile models");
    println!("  airform run        # Execute locally");

    Ok(())
}
