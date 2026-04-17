# Airform

Airform is a Rust-based dbt-compatible SQL compiler and runner that uses DuckDB as its execution engine. It compiles Jinja-templated SQL models using a custom Jinja engine (minijinja-based) and aims for full parity with dbt's compilation output.

## Building

```bash
cargo build -p airform              # debug build
cargo build -p airform --release    # release build
```

The debug binary lands at `target/debug/airform`.

## Testing

### Rust tests

```bash
cargo test                          # all tests
cargo test --test test_jinja        # jinja engine tests
cargo test --test test_jaffle_shop  # jaffle-shop integration
cargo test --test test_ecommerce    # ecommerce integration
cargo test --test test_compiler     # compiler tests
cargo test --test test_dbt_parity   # dbt parity tests
```

### Golden SQL parity tests

These compare airform-compiled SQL against dbt golden references using sqlglot AST normalization. See [TESTING.md](TESTING.md) for full details.

```bash
# Run all projects (slow — compiles each project with airform)
python3 scripts/test_golden_sql.py

# Run a single project
python3 scripts/test_golden_sql.py jira

# Run a single model within a project
python3 scripts/test_golden_sql.py jira -m int_jira__issue_users

# Show diffs for mismatches
python3 scripts/test_golden_sql.py jira -v

# Skip cargo build (use existing binary)
python3 scripts/test_golden_sql.py --no-build

# Force rebuild
python3 scripts/test_golden_sql.py --rebuild
```

Results are saved to `tests/golden-results.json` after each run.

## Key crates

- `crates/airform-jinja/` — Jinja engine (minijinja-based), macro loading, dbt builtin macros
- `crates/airform-loader/` — Project loading, manifest parsing, dependency resolution
- `crates/airform/` — CLI, compilation, execution

## Jinja engine architecture

The Jinja engine (`crates/airform-jinja/src/engine.rs`) uses a `return()` / `_get_return()` pattern to work around minijinja's lack of native early-return from macros. Key functions:

- `return(val)` — stores value in thread-local `LAST_RETURN_VALUE`
- `_get_return(fallback)` — consumes stored value or returns fallback
- `_peek_return(fallback)` — reads stored value WITHOUT consuming (used in dispatch bodies)
- `_clear_return()` — clears stored value to prevent stale leaks

Dispatch preprocessing replaces `adapter.dispatch('name')` calls with resolved target macros. The `wrap_set_macro_calls()` function wraps `{% set x = func(...) %}` with `_get_return()` to capture return values.

## Bundled macros

Global project macros (dbt builtins) live in `crates/airform-jinja/macros/global_project/*.sql`. These are embedded via `include_str!` at compile time. Third-party package macros (dbt_utils, fivetran_utils, etc.) come from the project's `dbt_packages/` directory.
