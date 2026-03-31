# Architecture

Airform is organized as a Rust workspace with eight crates, each responsible for a distinct stage of the compilation and execution pipeline.

## Crate structure

```
airform/
  Cargo.toml                    # Workspace root
  crates/
    airform-cli/                # CLI entry point and command dispatch
    airform-core/               # Shared types: config, node definitions, manifest
    airform-loader/             # File discovery and YAML/SQL loading
    airform-parser/             # SQL parsing and ref()/source() extraction
    airform-jinja/              # Jinja template rendering (minijinja)
    airform-compiler/           # Compilation pipeline (resolve refs, inject CTEs)
    airform-graph/              # DAG construction, topological sort, lineage
    airform-executor/           # Local execution via Apache DataFusion
```

### airform-core

The foundation crate. Defines all shared data types:

- **`DbtProject`** -- parsed `dbt_project.yml` with all paths, model configs, vars, and dispatch settings.
- **`DbtProfiles` / `DbtProfile` / `DbtTarget`** -- parsed `profiles.yml` with adapter type, schema, database, and threads.
- **`Materialization`** -- enum: `View`, `Table`, `Incremental`, `Ephemeral`.
- **`NodeConfig`** -- per-node configuration (materialization, schema, alias, tags, unique_key, etc.).
- **`ModelNode`** -- a model in the DAG with raw SQL, compiled SQL, config, dependencies, columns, and injected CTEs.
- **`SeedNode`** -- a CSV seed with path and config.
- **`TestNode`** -- a test with raw/compiled SQL and optional test metadata.
- **`SourceDefinition`** -- a source table with schema, identifier, and column definitions.
- **`ManifestNode`** -- union enum over Model, Seed, Test, Snapshot, and Source.
- **`ResourceType`** -- enum: Model, Seed, Test, Snapshot, Source, Analysis, Macro, Exposure.
- **`RefCall` / `SourceCall` / `DependsOn`** -- dependency references extracted from SQL.
- **`ColumnDef` / `TestDef`** -- column metadata and test definitions from schema YAML.

### airform-loader

Discovers and loads project files from disk:

- Walks configured model, seed, test, snapshot, and analysis paths.
- Reads `.sql` files and parses `dbt_project.yml` and `profiles.yml`.
- Reads `_schema.yml` / `_sources.yml` files for source definitions and column metadata.

### airform-parser

Extracts dependency information from SQL:

- Finds `{{ ref('model_name') }}` calls (with optional package and version).
- Finds `{{ source('source_name', 'table_name') }}` calls.
- Extracts `{{ config(...) }}` blocks and parses them into `NodeConfig`.
- Builds `DependsOn` structures for each node.

### airform-jinja

Handles Jinja template rendering using the `minijinja` library:

- Registers custom functions: `ref()`, `source()`, `config()`, `var()`, `is_incremental()`, `this`.
- Renders model SQL by replacing Jinja expressions with resolved table references.
- Supports Jinja control flow (`{% if %}`, `{% for %}`, etc.).

### airform-compiler

Orchestrates the full compilation pipeline:

1. Load the project (via `airform-loader`).
2. Parse all SQL files (via `airform-parser`).
3. Build the dependency graph (via `airform-graph`).
4. Resolve `ref()` calls to fully qualified table names.
5. Inject CTEs for ephemeral model dependencies.
6. Render Jinja templates (via `airform-jinja`).
7. Apply model configs from `dbt_project.yml` (cascading by directory path).
8. Produce a `Manifest` with all compiled nodes.

### airform-graph

Builds and analyzes the project DAG:

- Constructs a directed graph from `DependsOn` relationships (using `petgraph`).
- Provides topological sort for execution ordering.
- Computes upstream ancestors and downstream dependents for any node.
- Implements column-level lineage analysis (see below).

**Column lineage** (`lineage.rs`) uses regex-based SQL analysis:

- Maps CTE/alias names to upstream model names.
- Resolves multi-hop CTE chains.
- Parses final SELECT blocks to extract output columns.
- Classifies column dependencies as `Copy`, `Transform`, or `Scan`.
- Supports recursive tracing through the full DAG.

### airform-executor

Executes compiled SQL locally using Apache DataFusion:

- Creates a `SessionContext` for in-memory SQL execution.
- Loads seed CSVs as DataFusion tables.
- Executes models in topological order.
- Handles materialization strategies:
  - **View**: registered as a DataFusion view (lazy).
  - **Table**: executed, results stored as in-memory `MemTable`.
  - **Incremental**: treated as table in local mode.
  - **Ephemeral**: skipped (already injected as CTEs by the compiler).
- Runs ad-hoc queries against the session context.
- Executes generic tests (not_null, unique, accepted_values, relationships) by generating and running test SQL.

### airform-cli

The user-facing CLI, built with `clap`:

- Parses command-line arguments and dispatches to command handlers.
- Commands: `init`, `parse`, `compile`, `run`, `test`, `seed`, `debug`, `lineage`, `ls`, `clean`, `docs-generate`, `format`.
- Configures `tracing-subscriber` for logging.
- Uses `tokio` async runtime for execution.

## Execution pipeline

When you run `airform run`, the following happens:

```
1. CLI parses arguments
2. Loader reads dbt_project.yml, profiles.yml, SQL files, YAML schemas
3. Parser extracts ref(), source(), config() from each SQL file
4. Graph builds DAG from dependencies, performs topological sort
5. Compiler resolves refs to table names, injects ephemeral CTEs, renders Jinja
6. Executor creates DataFusion session context
7. Executor loads seed CSVs as tables
8. Executor runs each model's compiled SQL in topological order
   - Views: registered as DataFusion views
   - Tables: executed, results stored in memory
   - Ephemeral: skipped (already CTEs)
9. Results are reported (success/error/skip counts, timing)
```

## Key dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| `clap` | 4 | CLI argument parsing with derive macros |
| `serde` / `serde_yaml` / `serde_json` | 1 / 0.9 / 1 | YAML and JSON serialization |
| `minijinja` | 2 | Jinja2-compatible template rendering |
| `datafusion` | 46 | Local SQL execution engine (Apache Arrow-based) |
| `petgraph` | 0.7 | Graph data structure for DAG operations |
| `regex` | 1 | SQL pattern matching for lineage analysis |
| `tokio` | 1 | Async runtime |
| `tracing` | 0.1 | Structured logging |
| `walkdir` | 2 | Recursive directory traversal |
| `tabled` | 0.18 | Table formatting for CLI output |
| `colored` | 3 | Terminal color output |

## Design principles

- **dbt compatibility**: Airform reads standard `dbt_project.yml` and `profiles.yml` files and supports the same `ref()`, `source()`, and `config()` semantics.
- **Local-first execution**: All execution happens in-process via DataFusion. No warehouse connection is needed for development and testing.
- **Modular crates**: Each stage of the pipeline is a separate crate with clear boundaries, enabling independent testing and potential reuse.
- **Performance**: Written in Rust with Apache Arrow-based DataFusion for fast local execution.
