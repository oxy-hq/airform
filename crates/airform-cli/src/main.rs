mod commands;

use clap::{Parser, Subcommand};
use std::path::PathBuf;
use tracing_subscriber::EnvFilter;

#[derive(Parser)]
#[command(
    name = "airform",
    about = "A Rust-powered dbt-compatible SQL transformation engine",
    version,
    long_about = "Airform is a high-performance, dbt-compatible SQL transformation framework \
                   built in Rust. It compiles and executes dbt projects locally using Apache \
                   DataFusion, with no warehouse connection required for development."
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Path to dbt project directory (defaults to current directory)
    #[arg(long, global = true, default_value = ".")]
    project_dir: PathBuf,

    /// Enable debug logging
    #[arg(long, global = true)]
    debug: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Initialize a new dbt project
    Init {
        /// Project name
        name: String,
    },

    /// Parse the project and validate SQL
    Parse,

    /// Compile models (resolve refs, render Jinja)
    Compile {
        /// Select specific models to compile
        #[arg(short, long)]
        select: Option<String>,

        /// Exclude specific models
        #[arg(long)]
        exclude: Option<String>,

        /// Output format (table, json, csv)
        #[arg(long, default_value = "table")]
        format: String,

        /// Which target to use from profiles.yml
        #[arg(short, long)]
        target: Option<String>,

        /// Disable cache (force full recompile)
        #[arg(long)]
        no_cache: bool,
    },

    /// Run models (compile + execute locally via DataFusion)
    Run {
        /// Select specific models to run
        #[arg(short, long)]
        select: Option<String>,

        /// Exclude specific models
        #[arg(long)]
        exclude: Option<String>,

        /// Number of threads for parallel execution
        #[arg(long, default_value = "4")]
        threads: usize,

        /// Full refresh (ignore incremental logic)
        #[arg(long)]
        full_refresh: bool,

        /// Run an ad-hoc SQL query against the compiled workspace
        #[arg(short = 'q', long = "query")]
        query: Option<String>,

        /// Output format (table, json, csv)
        #[arg(long, default_value = "table")]
        format: String,

        /// Which target to use from profiles.yml
        #[arg(short, long)]
        target: Option<String>,
    },

    /// Run tests
    Test {
        /// Select specific models/tests
        #[arg(short, long)]
        select: Option<String>,

        /// Which target to use from profiles.yml
        #[arg(short, long)]
        target: Option<String>,
    },

    /// Load seed CSV files into the local execution context
    Seed,

    /// Show debug information about the project
    Debug,

    /// Show the dependency lineage for a model
    Lineage {
        /// Model name
        model: String,

        /// Show upstream dependencies (ancestors)
        #[arg(long)]
        upstream: bool,

        /// Show downstream dependents
        #[arg(long)]
        downstream: bool,

        /// Trace column-level lineage for a specific column
        #[arg(short, long)]
        column: Option<String>,
    },

    /// List project resources
    Ls {
        /// Filter by resource type (model, source, test, seed, snapshot)
        #[arg(short, long)]
        resource_type: Option<String>,

        /// Output format (table, json, name, csv)
        #[arg(long, default_value = "table")]
        output: String,

        /// Select specific nodes
        #[arg(short, long)]
        select: Option<String>,

        /// Output format alias (table, json, csv)
        #[arg(long)]
        format: Option<String>,
    },

    /// Clean target directory
    Clean,

    /// Generate and serve documentation (writes manifest.json)
    DocsGenerate,

    /// Analyze SQL: validate correctness and extract column-level lineage via logical plans
    Analyze {
        /// Select specific models to analyze
        #[arg(short, long)]
        select: Option<String>,

        /// Which target to use from profiles.yml
        #[arg(short, long)]
        target: Option<String>,

        /// Show column-level lineage for a specific model
        #[arg(long)]
        lineage: bool,

        /// Trace lineage for a specific column (requires --lineage and model name via --select)
        #[arg(short, long)]
        column: Option<String>,
    },

    /// Format SQL files (uppercase keywords, consistent indentation)
    Format {
        /// Check mode: exit non-zero if files would change (for CI)
        #[arg(long)]
        check: bool,
    },
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();

    // Initialize tracing
    let filter = if cli.debug {
        EnvFilter::new("debug")
    } else {
        EnvFilter::new("info")
    };
    tracing_subscriber::fmt()
        .with_env_filter(filter)
        .with_target(false)
        .without_time()
        .init();

    let project_dir = cli.project_dir.canonicalize().unwrap_or(cli.project_dir);

    match cli.command {
        Commands::Init { name } => commands::init::run(&project_dir, &name),
        Commands::Parse => commands::parse::run(&project_dir),
        Commands::Compile {
            select,
            exclude,
            format,
            target,
            no_cache,
        } => commands::compile::run(
            &project_dir,
            select.as_deref(),
            exclude.as_deref(),
            &format,
            target.as_deref(),
            no_cache,
        ),
        Commands::Run {
            select,
            exclude,
            threads: _,
            full_refresh: _,
            query,
            format,
            target,
        } => {
            commands::run::run(
                &project_dir,
                select.as_deref(),
                exclude.as_deref(),
                query.as_deref(),
                &format,
                target.as_deref(),
            )
            .await
        }
        Commands::Test { select, target } => {
            commands::test::run(&project_dir, select.as_deref(), target.as_deref()).await
        }
        Commands::Seed => commands::seed::run(&project_dir).await,
        Commands::Debug => commands::debug::run(&project_dir),
        Commands::Lineage {
            model,
            upstream,
            downstream,
            column,
        } => commands::lineage::run(
            &project_dir,
            &model,
            upstream,
            downstream,
            column.as_deref(),
        ),
        Commands::Ls {
            resource_type,
            output,
            select,
            format,
        } => {
            let effective_output = format.as_deref().unwrap_or(&output);
            commands::ls::run(
                &project_dir,
                resource_type.as_deref(),
                effective_output,
                select.as_deref(),
            )
        }
        Commands::Analyze {
            select,
            target,
            lineage,
            column,
        } => {
            commands::analyze::run(
                &project_dir,
                select.as_deref(),
                target.as_deref(),
                lineage,
                column.as_deref(),
            )
            .await
        }
        Commands::Clean => commands::clean::run(&project_dir),
        Commands::DocsGenerate => commands::docs::run(&project_dir),
        Commands::Format { check } => commands::format::run(&project_dir, check),
    }
}
