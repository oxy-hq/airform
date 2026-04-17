# Golden SQL Parity Tests

Golden SQL tests verify that airform's Jinja compilation produces semantically equivalent SQL to dbt. They are the primary measure of dbt compatibility.

## How it works

1. **Golden references** (`tests/golden/<project>/expected/*.sql`) contain dbt-compiled SQL for each model
2. **Compat projects** (`tests/compat-projects/<project>/`) are dbt projects configured for airform
3. The test script compiles each project with airform, then compares output against golden refs using sqlglot AST normalization

## Prerequisites

```bash
cargo build -p airform   # done automatically by the script
pip install sqlglot       # SQL normalization library
```

## Running tests

```bash
# All projects (17 projects, ~670 models — takes several minutes)
python3 scripts/test_golden_sql.py

# Single project
python3 scripts/test_golden_sql.py jira

# Single model (fastest for iterating on a fix)
python3 scripts/test_golden_sql.py jira -m int_jira__issue_users

# Multiple projects
python3 scripts/test_golden_sql.py jira zendesk mixpanel

# Show diffs for mismatches
python3 scripts/test_golden_sql.py jira -v

# Skip auto-rebuild (use existing target/debug/airform)
python3 scripts/test_golden_sql.py --no-build

# Force rebuild even if binary exists
python3 scripts/test_golden_sql.py --rebuild
```

## Results

After each run, results are saved to `tests/golden-results.json` with:
- Timestamp
- Summary (total, passed, failed, skipped, pass rate)
- Per-project breakdowns with per-model pass/fail/skip status

## Known failure categories

- **`_tmp` models**: `fivetran_utils.union_data()` needs a real DB connection to enumerate source tables. dbt produces dummy SQL; airform produces table references. These are expected mismatches.
- **`_base` models**: Some adapter-dependent models that behave differently outside a warehouse context.
- **`generate_series`**: Uses `return()` inside a `for` loop. minijinja doesn't support early-return from macros, so the last loop iteration wins instead of the correct one.
- **Ephemeral CTE models**: Models with `__dbt__cte__` inlined CTEs are automatically skipped (different inlining strategies).

## Generating golden references

To regenerate golden SQL references from dbt:

```bash
python3 scripts/generate_golden_sql.py [project]
```

This requires a working dbt installation and compiles each project with dbt, copying the output to `tests/golden/<project>/expected/`.
