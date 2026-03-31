# Airform

**A Rust-powered, dbt-compatible SQL transformation engine.**

Compile, run, and test [dbt](https://www.getdbt.com/) projects locally using [Apache DataFusion](https://datafusion.apache.org/) -- no warehouse connection required. Inspired by [SDF](https://www.sdf.com/) (now dbt-fusion).

---

## Highlights

- **Full dbt syntax compatibility** -- `dbt_project.yml`, `profiles.yml`, `ref()`, `source()`, `config()`, `var()`, `env_var()`, `is_incremental()`
- **Local execution via DataFusion** -- develop and iterate without touching a warehouse
- **Fast** -- single ~75 MB binary; compiles the jaffle-shop example (5 models) in 0.16 s, the ecommerce-analytics example (19 models) in 0.33 s
- **Column-level lineage** -- trace how a column flows through your DAG
- **Materializations** -- `view`, `table`, `incremental`, `ephemeral` (with automatic CTE injection)
- **Seeds & tests** -- CSV loading, generic tests (`not_null`, `unique`, `accepted_values`, `relationships`)
- **SQL formatting** -- built-in formatter with `--check` mode for CI
- **Incremental rebuilds** -- file fingerprinting and caching so unchanged models are skipped
- **Custom macros** -- load Jinja macros from a `macros/` directory
- **Artifacts** -- generates `manifest.json` and `run_results.json`

---

## Installation

### From source

```bash
git clone https://github.com/robertyi/airform.git
cd airform
cargo build --release
# Binary is at target/release/airform
```

### With cargo install

```bash
cargo install --path crates/airform-cli
```

> Requires Rust 2024 edition (1.85+).

---

## Quick start

```bash
# Scaffold a new project
airform init my_project
cd my_project

# Load seed CSV files
airform seed

# Compile all models (resolve refs, render Jinja)
airform compile

# Run models locally via DataFusion
airform run

# Run tests
airform test

# Run an ad-hoc query against the compiled workspace
airform run --query "SELECT * FROM customers LIMIT 10"
```

### Try the example projects

```bash
cd examples/jaffle-shop
airform seed && airform run

cd examples/ecommerce-analytics   # 19 models, 7 seeds, incremental + ephemeral
airform seed && airform run
```

---

## CLI reference

All commands accept the global flags `--project-dir <PATH>` and `--debug`.

| Command | Description |
|---------|-------------|
| `init <name>` | Scaffold a new dbt project |
| `parse` | Parse the project and validate SQL |
| `compile` | Compile models (resolve refs, render Jinja) |
| `run` | Compile and execute models locally via DataFusion |
| `test` | Run generic and custom tests |
| `seed` | Load seed CSV files into the local execution context |
| `debug` | Show debug information about the project |
| `lineage <model>` | Show the dependency lineage for a model |
| `ls` | List project resources |
| `clean` | Remove the `target/` directory |
| `docs-generate` | Generate documentation artifacts (`manifest.json`) |
| `format` | Format SQL files (uppercase keywords, consistent indentation) |

### compile

```bash
airform compile                           # compile everything
airform compile -s my_model               # compile a single model
airform compile -s +my_model              # model and all upstream deps
airform compile -s my_model+              # model and all downstream dependents
airform compile -s path:models/staging    # all models under a path
airform compile -s tag:finance            # all models with a tag
airform compile --exclude my_model        # compile everything except my_model
airform compile --no-cache                # force full recompile
airform compile --target prod             # use a specific profiles.yml target
airform compile --format json             # output as JSON (also: table, csv)
```

### run

```bash
airform run                               # run all models
airform run -s my_model                   # run a single model
airform run --full-refresh                # ignore incremental logic
airform run -q "SELECT * FROM orders"     # ad-hoc SQL query
airform run --threads 8                   # parallel execution threads
airform run --format csv                  # output format (table, json, csv)
airform run --target prod                 # use a specific target
```

### test

```bash
airform test                              # run all tests
airform test -s my_model                  # run tests for a specific model
airform test --target prod                # test against a specific target
```

### lineage

```bash
airform lineage my_model                  # show full lineage
airform lineage my_model --upstream       # ancestors only
airform lineage my_model --downstream     # dependents only
airform lineage my_model --column revenue # column-level lineage
```

### ls

```bash
airform ls                                # list all resources
airform ls -r model                       # filter by type (model, source, test, seed, snapshot)
airform ls -s +my_model                   # select specific nodes
airform ls --output json                  # output format (table, json, name, csv)
```

### format

```bash
airform format                            # format all SQL files in place
airform format --check                    # check mode (exit 1 if files would change)
```

---

## Project structure

Airform is organized as a Cargo workspace with eight crates:

```
crates/
  airform-core/        Core types: Project, Model, Source, Seed, Test, Materialization
  airform-loader/      Reads dbt_project.yml, profiles.yml, schema.yml; discovers models, seeds, sources
  airform-jinja/       Jinja rendering: ref(), source(), config(), var(), env_var(), is_incremental()
  airform-parser/      SQL parsing, column extraction, dependency detection
  airform-graph/       DAG construction, topological sort, node selection (+model, model+, path:, tag:)
  airform-compiler/    Compilation pipeline: resolve refs, inject CTEs for ephemeral models, caching
  airform-executor/    DataFusion-based local execution, materializations, information schema
  airform-cli/         CLI entry point (clap), orchestrates all other crates
```

### Example projects

```
examples/
  jaffle-shop/               Classic dbt tutorial project (5 models, 3 seeds)
  ecommerce-analytics/       Larger project (19 models, 7 seeds, ephemeral + incremental)
```

---

## Configuration

Airform reads standard dbt configuration files.

### dbt_project.yml

```yaml
name: my_project
version: "1.0.0"
profile: my_project

model-paths: ["models"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
target-path: "target"
clean-targets: ["target"]

vars:
  start_date: "2024-01-01"
```

### profiles.yml

Stored at `~/.dbt/profiles.yml` or in the project root:

```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: datafusion
      schema: main
    prod:
      type: datafusion
      schema: production
```

### Model configuration

Via `config()` blocks in SQL or in `schema.yml`:

```sql
{{ config(materialized='incremental', unique_key='id') }}

SELECT *
FROM {{ ref('stg_orders') }}
{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

### Node selection syntax

Airform supports dbt-style graph operators in `-s` / `--select`:

| Syntax | Meaning |
|--------|---------|
| `my_model` | Single model |
| `+my_model` | Model and all upstream ancestors |
| `my_model+` | Model and all downstream dependents |
| `+my_model+` | Full lineage (upstream + downstream) |
| `path:models/staging` | All models under a directory |
| `tag:finance` | All models with a specific tag |

---

## Comparison

| Feature | dbt Core | SQLMesh | Airform |
|---------|----------|---------|---------|
| Language | Python | Python | Rust |
| Local execution | Limited (DuckDB adapter) | Built-in | Built-in (DataFusion) |
| Startup time | Seconds | Seconds | Instant |
| Single binary | No | No | Yes (~75 MB) |
| dbt syntax compatible | Yes | Partial | Yes |
| Column-level lineage | No (dbt Cloud only) | Yes | Yes |
| Incremental by default | No | Yes | File-fingerprint caching |
| SQL formatter | No (needs sqlfmt) | Built-in | Built-in |

---

## Contributing

Contributions are welcome. To get started:

```bash
git clone https://github.com/robertyi/airform.git
cd airform
cargo build
cargo test
```

Run the examples to verify changes:

```bash
cd examples/jaffle-shop && cargo run --bin airform -- seed && cargo run --bin airform -- run
```

Please open an issue before submitting large changes.

---

## License

Apache-2.0. See [LICENSE](LICENSE) for details.
