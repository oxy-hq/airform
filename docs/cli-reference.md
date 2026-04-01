# CLI Reference

Airform is invoked as `airform <command> [options]`. All commands accept the global flags listed below.

## Global flags

| Flag | Description |
|------|-------------|
| `--project-dir <PATH>` | Path to the dbt project directory. Defaults to the current directory (`.`). |
| `--debug` | Enable debug-level logging output. |
| `--version` | Print the airform version and exit. |
| `--help` | Print help information. |

## Commands

### init

Initialize a new dbt project with the standard directory structure.

```bash
airform init <project_name>
```

**Arguments:**

| Argument | Required | Description |
|----------|----------|-------------|
| `project_name` | yes | Name of the new project |

**Example:**

```bash
airform init my_analytics
```

Creates a directory `my_analytics/` with `dbt_project.yml`, `profiles.yml`, and standard subdirectories.

---

### parse

Parse the project and validate SQL files. Does not compile or execute.

```bash
airform parse
```

This reads all project files, resolves source definitions, and checks for basic structural issues.

---

### compile

Compile models by resolving `ref()` and `source()` calls and rendering Jinja templates. Compiled SQL is written to the target directory.

```bash
airform compile [options]
```

**Options:**

| Flag | Short | Description |
|------|-------|-------------|
| `--select <SELECTOR>` | `-s` | Select specific models to compile |
| `--exclude <SELECTOR>` | | Exclude specific models from compilation |
| `--format <FORMAT>` | | Output format: `table`, `json`, `csv`. Default: `table` |
| `--target <TARGET>` | `-t` | Which target to use from profiles.yml |
| `--no-cache` | | Disable cache and force a full recompile |

**Examples:**

```bash
# Compile all models
airform compile

# Compile only staging models
airform compile --select staging

# Compile with JSON output
airform compile --format json

# Compile against the prod target
airform compile --target prod

# Force full recompile
airform compile --no-cache
```

---

### analyze

Validate SQL correctness and extract column-level lineage by parsing compiled SQL into DataFusion logical plans. This catches type errors, invalid column references, and malformed SQL without hitting a warehouse.

```bash
airform analyze [options]
```

**Options:**

| Flag | Short | Description |
|------|-------|-------------|
| `--select <MODEL>` | `-s` | Show inferred schema and lineage for a specific model |
| `--target <TARGET>` | `-t` | Which target to use from profiles.yml |
| `--lineage` | | Show column-level lineage |
| `--column <NAME>` | `-c` | Trace lineage for a specific column (use with `--select`) |

**Examples:**

```bash
# Validate all models and show diagnostics
airform analyze

# Show inferred schema for a model
airform analyze --select customers

# Show column-level lineage for all models
airform analyze --lineage

# Show lineage for a specific model
airform analyze --select customers --lineage

# Trace a single column back through the DAG
airform analyze --select customers --column customer_lifetime_value

# Use a specific target
airform analyze --target prod
```

---

### run

Compile and execute models locally via DataFusion. Models are executed in topological (dependency) order.

```bash
airform run [options]
```

**Options:**

| Flag | Short | Description |
|------|-------|-------------|
| `--select <SELECTOR>` | `-s` | Select specific models to run |
| `--exclude <SELECTOR>` | | Exclude specific models |
| `--threads <N>` | | Number of threads for parallel execution. Default: `4` |
| `--full-refresh` | | Ignore incremental logic and rebuild from scratch |
| `--query <SQL>` | `-q` | Run an ad-hoc SQL query against the compiled workspace |
| `--format <FORMAT>` | | Output format: `table`, `json`, `csv`. Default: `table` |
| `--target <TARGET>` | `-t` | Which target to use from profiles.yml |

**Examples:**

```bash
# Run all models
airform run

# Run a single model and its dependencies
airform run --select customers

# Run and then query the results
airform run -q "SELECT * FROM customers LIMIT 10"

# Run with table-format output
airform run --format table

# Full refresh incremental models
airform run --full-refresh

# Use the prod target
airform run --target prod
```

---

### test

Run generic (schema) tests defined in `_schema.yml` files.

```bash
airform test [options]
```

**Options:**

| Flag | Short | Description |
|------|-------|-------------|
| `--select <SELECTOR>` | `-s` | Select specific models/tests to run |
| `--target <TARGET>` | `-t` | Which target to use from profiles.yml |

**Examples:**

```bash
# Run all tests
airform test

# Run tests for a specific model
airform test --select customers
```

---

### seed

Load seed CSV files into the local DataFusion execution context.

```bash
airform seed
```

Reads all `.csv` files from configured `seed-paths` and registers them as tables.

---

### lineage

Show dependency lineage for a model, including optional column-level tracing.

```bash
airform lineage <model> [options]
```

**Arguments:**

| Argument | Required | Description |
|----------|----------|-------------|
| `model` | yes | Name of the model to analyze |

**Options:**

| Flag | Short | Description |
|------|-------|-------------|
| `--upstream` | | Show upstream dependencies (ancestors) |
| `--downstream` | | Show downstream dependents |
| `--column <NAME>` | `-c` | Trace column-level lineage for a specific column |

**Examples:**

```bash
# Show full lineage (both directions)
airform lineage customers

# Show only upstream
airform lineage customers --upstream

# Show only downstream
airform lineage stg_orders --downstream

# Trace a specific column
airform lineage customers --column customer_lifetime_value
```

---

### ls

List project resources with optional filtering.

```bash
airform ls [options]
```

**Options:**

| Flag | Short | Description |
|------|-------|-------------|
| `--resource-type <TYPE>` | `-r` | Filter by type: `model`, `source`, `test`, `seed`, `snapshot` |
| `--output <FORMAT>` | | Output format: `table`, `json`, `name`, `csv`. Default: `table` |
| `--select <SELECTOR>` | `-s` | Select specific nodes |
| `--format <FORMAT>` | | Output format alias (same as `--output`) |

**Examples:**

```bash
# List all resources
airform ls

# List only models
airform ls --resource-type model

# List sources as JSON
airform ls -r source --format json

# List by name only
airform ls --output name
```

---

### debug

Show debug information about the project, including configuration details and environment.

```bash
airform debug
```

---

### docs-generate

Generate documentation artifacts (writes `manifest.json` to the target directory).

```bash
airform docs-generate
```

---

### format

Format SQL files with consistent style (uppercase keywords, consistent indentation).

```bash
airform format [options]
```

**Options:**

| Flag | Description |
|------|-------------|
| `--check` | Check mode: exit with non-zero status if any files would change. Useful for CI. |

**Examples:**

```bash
# Format all SQL files in-place
airform format

# Check formatting without modifying files
airform format --check
```

---

### clean

Remove the target directory and other configured clean targets.

```bash
airform clean
```

Removes all directories listed in `clean-targets` in `dbt_project.yml` (default: `target/` and `dbt_packages/`).
