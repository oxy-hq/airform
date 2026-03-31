# Migration from dbt

This guide is for existing dbt users who want to use airform. Airform is designed to be compatible with dbt projects, so in most cases you can point airform at your existing project and it will work.

## What stays the same

Airform reads the same project files and supports the same core abstractions as dbt:

- **dbt_project.yml** -- same format, same keys (both hyphenated and underscored forms).
- **profiles.yml** -- same structure with profile names, targets, and outputs.
- **Model SQL files** -- same `{{ ref() }}`, `{{ source() }}`, `{{ config() }}` syntax.
- **Source definitions** -- same `_sources.yml` format.
- **Schema tests** -- same `_schema.yml` format with `not_null`, `unique`, `accepted_values`, `relationships`.
- **Seeds** -- same CSV files in the `seeds/` directory.
- **Materializations** -- `view`, `table`, `incremental`, `ephemeral` all supported.
- **Project structure** -- same directory layout (models/, seeds/, tests/, macros/, etc.).

## What is different

### Local execution with DataFusion

The biggest difference: airform executes all SQL locally using Apache DataFusion instead of sending queries to a warehouse. This means:

- No warehouse credentials or connection needed for development.
- Execution is fast and entirely in-process.
- You use `type: datafusion` in your profiles.yml instead of `type: bigquery`, `type: snowflake`, etc.

Update your `profiles.yml`:

```yaml
# Before (dbt with Snowflake)
my_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: my_account
      user: my_user
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      database: analytics
      schema: dev
      threads: 4

# After (airform with DataFusion)
my_project:
  target: dev
  outputs:
    dev:
      type: datafusion
      schema: main
      threads: 4
```

### CLI command mapping

Most commands map directly:

| dbt command | airform command | Notes |
|-------------|-----------------|-------|
| `dbt init` | `airform init` | Same behavior |
| `dbt parse` | `airform parse` | Same behavior |
| `dbt compile` | `airform compile` | Same behavior |
| `dbt run` | `airform run` | Executes locally via DataFusion |
| `dbt test` | `airform test` | Same test types |
| `dbt seed` | `airform seed` | Same behavior |
| `dbt debug` | `airform debug` | Same behavior |
| `dbt clean` | `airform clean` | Same behavior |
| `dbt docs generate` | `airform docs-generate` | Hyphenated subcommand |
| `dbt ls` | `airform ls` | Same behavior |

Additional airform commands not in dbt:

| Command | Description |
|---------|-------------|
| `airform lineage <model>` | Show table and column lineage |
| `airform format` | Format SQL files |
| `airform run --query <SQL>` | Run ad-hoc SQL queries against the workspace |

### Adapter differences

Since airform uses DataFusion (which speaks ANSI SQL), some warehouse-specific SQL features may not work:

- **Warehouse-specific functions**: Replace Snowflake/BigQuery/Redshift-specific functions with ANSI SQL equivalents. For example, use `CAST(x AS DATE)` instead of `x::DATE` (Postgres syntax).
- **Data types**: DataFusion supports standard types (INT, BIGINT, VARCHAR, BOOLEAN, DATE, TIMESTAMP, FLOAT, DOUBLE, DECIMAL). Warehouse-specific types like `VARIANT`, `SUPER`, or `STRUCT` are not available.
- **Semi-structured data**: JSON parsing functions differ. Use DataFusion's arrow-based functions.
- **MERGE statements**: Not available in DataFusion. Incremental models are treated as full table rebuilds in local mode.

### Jinja support

Airform uses `minijinja` (a Rust Jinja2 implementation) for template rendering. Core Jinja features work:

- `{{ ref('model') }}` and `{{ source('src', 'table') }}`
- `{{ config(...) }}`
- `{{ var('key') }}`
- `{% if %}` / `{% for %}` / `{% set %}` control flow
- `{{ is_incremental() }}`

**Not yet supported:**

- Custom Jinja macros (`.sql` files in `macros/` are discovered but macro dispatch is limited).
- `env_var()` in profiles.yml.
- dbt packages (`dbt_packages/`) and `packages.yml`.
- `{{ this }}` in all contexts (basic support exists).

### Incremental models

Incremental models compile and run, but in local mode they execute as full table rebuilds (equivalent to `--full-refresh`). The `is_incremental()` function is available, and the `unique_key` / `incremental_strategy` / `on_schema_change` config properties are parsed, but merge/append logic is not applied locally.

### Tests

Airform supports the four built-in generic test types:

- `not_null`
- `unique`
- `accepted_values`
- `relationships`

**Not yet supported:**

- Custom generic tests (custom test macros in `tests/generic/`).
- Singular tests (standalone `.sql` files in `tests/`).
- `dbt_utils` or other package-based tests.
- Test severity and warn/error thresholds.

### Snapshots

Snapshot nodes are parsed and appear in the DAG, but snapshot execution (SCD Type 2 logic) is not implemented for local mode.

## Step-by-step migration

### 1. Install airform

```bash
git clone https://github.com/your-org/airform.git
cd airform
cargo build --release
cp target/release/airform /usr/local/bin/
```

### 2. Update profiles.yml

Create an airform-compatible target alongside your existing warehouse targets:

```yaml
my_project:
  target: local        # Switch default to local
  outputs:
    local:
      type: datafusion
      schema: main
      threads: 4
    snowflake:          # Keep existing target for production
      type: snowflake
      # ... existing config
```

### 3. Verify parsing

```bash
cd /path/to/your/dbt/project
airform parse
```

Fix any parsing errors. Common issues:
- Warehouse-specific SQL syntax in model files.
- Custom macros that are not yet supported.

### 4. Load seeds and run

```bash
airform seed
airform run
```

### 5. Run tests

```bash
airform test
```

### 6. Explore lineage

```bash
airform ls --resource-type model
airform lineage my_model --upstream
airform lineage my_model --column important_column
```

### 7. Use ad-hoc queries for exploration

```bash
airform run -q "SELECT * FROM my_model LIMIT 10"
airform run -q "SELECT count(*) FROM my_model"
```

## When to use airform vs. dbt

| Use case | Recommended tool |
|----------|-----------------|
| Local development and iteration | airform |
| Quick data validation and exploration | airform |
| Column-level lineage analysis | airform |
| CI testing without warehouse access | airform |
| SQL formatting | airform |
| Production warehouse execution | dbt |
| Complex incremental/snapshot logic | dbt |
| dbt packages ecosystem | dbt |
| Custom Jinja macros | dbt |

Airform and dbt can coexist in the same project. Use airform for fast local development and dbt for warehouse deployment.
