# Configuration

Airform reads two YAML configuration files: `dbt_project.yml` (project-level settings) and `profiles.yml` (connection targets).

## dbt_project.yml

This file lives at the root of your project and defines its structure and default configurations.

### Full reference

```yaml
config-version: 2          # Required. Only version 2 is supported.

name: "my_project"          # Required. Project name (used in unique IDs and config keys).
version: "1.0.0"            # Optional. Semantic version of your project.
profile: "my_project"       # Optional. Which profile to use from profiles.yml.

# Directory paths (all relative to project root)
model-paths: ["models"]            # Default: ["models"]
seed-paths: ["seeds"]              # Default: ["seeds"]
test-paths: ["tests"]              # Default: ["tests"]
macro-paths: ["macros"]            # Default: ["macros"]
snapshot-paths: ["snapshots"]      # Default: ["snapshots"]
analysis-paths: ["analyses"]       # Default: ["analyses"]
target-path: "target"              # Default: "target"
clean-targets:                     # Default: ["target", "dbt_packages"]
  - "target"
  - "dbt_packages"

# Variables accessible via {{ var('key') }} in SQL
vars:
  my_var: "some_value"
  start_date: "2024-01-01"

# Model configurations (keyed by project name, then path)
models:
  my_project:
    +materialized: view            # Default materialization for all models
    staging:
      +materialized: view          # Override for models/staging/
    marts:
      +materialized: table         # Override for models/marts/

# Seed configurations
seeds:
  my_project:
    +schema: raw                   # Load seeds into the "raw" schema

# Environment configurations
environments:
  - name: dev
    target: dev
  - name: staging
    target: staging
    schema_prefix: "stg_"
  - name: prod
    target: prod

# Dispatch configuration for macro resolution
dispatch:
  - macro_namespace: dbt
    search_order: ["my_project", "dbt"]
```

### Path configuration

All path keys accept either a single string or a list of strings. Using the hyphenated form (`model-paths`) or the underscored form (`model_paths`) both work.

| Key | Default | Description |
|-----|---------|-------------|
| `model-paths` | `["models"]` | Directories to scan for `.sql` model files |
| `seed-paths` | `["seeds"]` | Directories to scan for `.csv` seed files |
| `test-paths` | `["tests"]` | Directories to scan for singular test `.sql` files |
| `macro-paths` | `["macros"]` | Directories to scan for Jinja macro files |
| `snapshot-paths` | `["snapshots"]` | Directories to scan for snapshot files |
| `analysis-paths` | `["analyses"]` | Directories to scan for analysis files |
| `target-path` | `"target"` | Output directory for compiled artifacts |
| `clean-targets` | `["target", "dbt_packages"]` | Directories removed by `airform clean` |

### Model configuration hierarchy

Model configs cascade from general to specific. More specific settings override less specific ones:

1. **dbt_project.yml root level** -- applies to all models
2. **dbt_project.yml directory level** -- applies to models in that directory
3. **In-model config() block** -- applies to that single model

Example:

```yaml
models:
  my_project:                      # All models in my_project
    +materialized: view
    staging:                       # models/staging/*
      +materialized: view
    marts:                         # models/marts/*
      +materialized: table
```

### Supported config properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `materialized` | string | `view` | Materialization strategy: `view`, `table`, `incremental`, `ephemeral` |
| `schema` | string | target schema | Custom schema name |
| `database` | string | target database | Custom database name |
| `alias` | string | filename | Custom table/view name |
| `tags` | list | `[]` | Tags for selection |
| `enabled` | boolean | `true` | Whether the model is enabled |
| `unique_key` | string | none | Unique key for incremental models |
| `incremental_strategy` | string | none | Strategy for incremental models |
| `on_schema_change` | string | none | Behavior when schema changes for incremental models |
| `meta` | object | `{}` | Arbitrary metadata |

Config keys in `dbt_project.yml` are prefixed with `+` to distinguish them from directory names.

## profiles.yml

The profiles file defines connection targets. Airform looks for it in the project root directory.

### Full reference

```yaml
my_project:                        # Profile name (matches dbt_project.yml "profile" key)
  target: dev                      # Default target to use
  outputs:
    dev:                           # Target name
      type: datafusion             # Adapter type
      schema: main                 # Default schema
      threads: 1                   # Parallel execution threads
    prod:
      type: datafusion
      schema: main
      threads: 4
```

### Target properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `type` | string | yes | Adapter type. Use `datafusion` for local execution. |
| `schema` | string | no | Default schema for model output |
| `database` | string | no | Default database |
| `threads` | integer | no | Number of parallel execution threads |

Additional adapter-specific properties can be included and are stored in the `extra` field.

### Selecting a target at runtime

Override the default target with the `--target` flag:

```bash
airform run --target prod
airform compile --target prod
airform test --target prod
```

## Environment variables

Airform respects the following environment variables:

| Variable | Description |
|----------|-------------|
| `RUST_LOG` | Controls log verbosity (e.g., `debug`, `info`, `warn`) |

You can also enable debug logging with the global `--debug` flag:

```bash
airform --debug run
```
