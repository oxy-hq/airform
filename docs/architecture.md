# Architecture

Airform is organized as a Rust workspace with nine crates, each responsible for a distinct stage of the compilation and execution pipeline.

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
    airform-analyzer/           # SQL comprehension: logical plan validation, schema inference, column lineage
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

- Registers custom functions: `ref()`, `source()`, `config()`, `var()`, `env_var()`, `is_incremental()`, `this`, `return()`.
- Renders model SQL by replacing Jinja expressions with resolved table references.
- Supports Jinja control flow (`{% if %}`, `{% for %}`, `{% set %}`, `{% do %}`).
- **Macro discovery** -- auto-loads `.sql` files from project `macros/` and `dbt_packages/` directories, registering all `{% macro %}` definitions.
- **Dispatch resolution** -- implements `adapter.dispatch()` with target-specific prefix resolution (e.g., `duckdb__my_macro`, `postgres__my_macro`, `default__my_macro`) and respects `dispatch:` config in `dbt_project.yml` for search order.
- **Built-in dbt macros** -- includes Rust-native implementations of common dbt macros (`generate_schema_name`, `star`, `datediff`, `dateadd`, `type_*`, `fill_staging_columns`, etc.).
- **Structured return values** -- `return()` passes lists, dicts, and other structured values through macro call boundaries (not just rendered text).

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

### airform-analyzer

Provides SQL comprehension by parsing compiled SQL into DataFusion logical plans without executing them. This is similar to what dbt-fusion (via SDF) does — understanding SQL semantics rather than treating it as opaque text.

Three capabilities from a single logical plan:

- **SQL validation**: Catches type mismatches (e.g., `Utf8 / Float64`), invalid column references, and malformed SQL at compile time, without hitting a warehouse. Errors cascade correctly — if a staging model fails validation, all downstream models report it.
- **Schema inference**: Resolves output schemas (column names and Arrow types) for every model by walking models in topological order. Seeds get schemas from CSV type inference (samples data rows to detect Int64/Float64/Utf8/Boolean). Sources fall back to matching seed CSV schemas when schema.yml lacks `data_type` annotations.
- **Column-level lineage**: Walks the logical plan tree to trace each output column back to its input columns, classifying dependencies as Copy (direct pass-through), Transform (derived via expression), or Scan (used in WHERE/JOIN/GROUP BY).

The analyzer registers empty `MemTable` tables with the correct schemas in a DataFusion `SessionContext` used purely for planning (never execution). As each model is analyzed in topological order, its inferred output schema is registered for downstream models to reference.

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
- Commands: `init`, `parse`, `compile`, `analyze`, `run`, `test`, `seed`, `debug`, `lineage`, `ls`, `clean`, `docs-generate`, `format`.
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

When you run `airform analyze`, the pipeline runs steps 1-5, then:

```
6. Analyzer creates a planning-only DataFusion session (no data)
7. Analyzer registers source/seed schemas (from schema.yml + CSV inference)
8. Analyzer plans each model's SQL in topological order
   - Validates SQL correctness (type checking, column existence)
   - Infers output schema and registers it for downstream models
   - Extracts column-level lineage from the logical plan
9. Diagnostics and lineage are reported
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

## Testing

### Unit and integration tests

Each crate has its own tests, runnable via `cargo test`. Integration tests in `tests/` exercise end-to-end compilation and execution:

- `test_jaffle_shop` -- validates the jaffle-shop example project end-to-end.
- `test_compat_execution` -- compiles and executes 66 real-world dbt packages locally.

### Golden SQL parity tests

The `tests/golden/` directory contains dbt-compiled SQL as reference outputs. The test script `scripts/test_golden_sql.py` compiles each project with airform and compares the output against the golden references using sqlglot AST normalization.

```
tests/
  golden/
    <project>/
      expected/
        <model>.sql     # dbt-compiled reference SQL
  compat-projects/
    <project>/          # Real dbt project with dbt_project.yml, models/, etc.
```

To run the golden SQL parity tests:

```bash
# Generate golden references from dbt (requires dbt installed)
python3 scripts/generate_golden_sql.py

# Compare airform output against golden references
python3 scripts/test_golden_sql.py --verbose
```

The comparison applies several normalization layers to handle expected differences between dbt and airform output:
- **Database prefix stripping** -- 3-part `database.schema.table` refs normalized to 2-part `schema.table`.
- **Type alias normalization** -- `FLOAT`/`REAL` to `DOUBLE`, `DECIMAL(N,M)` to `DECIMAL`, `NOW()` to `CURRENT_TIMESTAMP`.
- **Redundant cast removal** -- strips `CAST(... AS TIMESTAMP)` wrappers that dbt adds but airform omits.
- **Ephemeral CTE skipping** -- models with inlined `__dbt__cte__` CTEs are excluded (known structural difference in how ephemeral models are resolved).

### Contributing tests

To add a new test project:

1. Place the dbt project in `tests/compat-projects/<name>/` with a working `dbt_project.yml` and `profiles.yml`.
2. Run `python3 scripts/generate_golden_sql.py <name>` to generate golden references.
3. Run `python3 scripts/test_golden_sql.py <name> --verbose` to verify parity.

## Design principles

- **dbt compatibility**: Airform reads standard `dbt_project.yml` and `profiles.yml` files and supports the same `ref()`, `source()`, and `config()` semantics. Tested against 66 real-world dbt packages with 99.1% SQL parity.
- **Local-first execution**: All execution happens in-process via DataFusion. No warehouse connection is needed for development and testing.
- **Modular crates**: Each stage of the pipeline is a separate crate with clear boundaries, enabling independent testing and potential reuse.
- **Performance**: Written in Rust with Apache Arrow-based DataFusion for fast local execution.
