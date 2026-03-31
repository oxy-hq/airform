# Getting Started

Airform is a high-performance, dbt-compatible SQL transformation engine built in Rust. It compiles and executes dbt projects locally using Apache DataFusion, with no warehouse connection required for development.

## Prerequisites

- Rust toolchain (1.85+) installed via [rustup](https://rustup.rs/)
- A dbt-style project (or you can scaffold one with `airform init`)

## Installation

### Build from source

```bash
git clone https://github.com/your-org/airform.git
cd airform
cargo build --release
```

The binary will be at `target/release/airform`. Add it to your `PATH` or copy it to a directory already on your `PATH`:

```bash
cp target/release/airform /usr/local/bin/
```

### Verify installation

```bash
airform --version
```

## Creating your first project

Scaffold a new project with `airform init`:

```bash
airform init my_project
cd my_project
```

This creates the standard dbt project layout:

```
my_project/
  dbt_project.yml
  profiles.yml
  models/
  seeds/
  tests/
  macros/
  analyses/
  snapshots/
```

## Project structure

A minimal project needs two configuration files:

**dbt_project.yml** -- defines the project name, paths, and model configurations:

```yaml
config-version: 2
name: "my_project"
version: "1.0.0"
profile: "my_project"

model-paths: ["models"]
seed-paths: ["seeds"]
test-paths: ["tests"]

target-path: "target"
```

**profiles.yml** -- defines connection targets (airform uses DataFusion locally):

```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: datafusion
      schema: main
      threads: 1
```

## Writing your first model

Create a SQL file in the `models/` directory:

```sql
-- models/my_first_model.sql
select
    1 as id,
    'hello' as greeting
```

## Running your project

### Step 1: Parse and validate

```bash
airform parse
```

This reads your project files, validates SQL syntax, and resolves dependencies.

### Step 2: Compile

```bash
airform compile
```

Compilation resolves `ref()` and `source()` calls, renders Jinja templates, and writes compiled SQL to the `target/` directory.

### Step 3: Run

```bash
airform run
```

This compiles all models and executes them locally via DataFusion. Models are executed in dependency order (topological sort of the DAG).

### Step 4: Query results

Run an ad-hoc query against the compiled workspace:

```bash
airform run --query "SELECT * FROM my_first_model"
```

## Working with the example project

Airform ships with a `jaffle-shop` example that mirrors the classic dbt tutorial:

```bash
cd examples/jaffle-shop

# Load seed CSV data
airform seed

# Run all models
airform run

# Query the results
airform run -q "SELECT * FROM customers LIMIT 5"

# Run tests
airform test
```

The jaffle-shop project demonstrates:

- Source definitions (`_sources.yml`)
- Staging models using `source()` references
- Mart models using `ref()` references
- Schema tests (not_null, unique, accepted_values, relationships)
- Seed CSV loading
- View and table materializations

## Next steps

- [Configuration reference](configuration.md) -- all dbt_project.yml and profiles.yml options
- [Writing models](models.md) -- materializations, ref(), source(), config()
- [CLI reference](cli-reference.md) -- every command and flag
- [Migration from dbt](migration-from-dbt.md) -- guide for existing dbt users
