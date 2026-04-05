# airform task runner
# Install: cargo install just
# List all recipes: just --list

# Default recipe
default:
    @just --list

# ── Build ────────────────────────────────────────────────

# Build all crates
build:
    cargo build

# Build in release mode
build-release:
    cargo build --release

# ── Test ─────────────────────────────────────────────────

# Tier 1: unit tests + local integration (DataFusion only)
test:
    cargo test

# Tier 1: dialect normalization tests (Snowflake/BigQuery SQL compiled locally)
test-dialect:
    cargo test --test dialect_tests

# Tier 2: start Docker databases (auto-selects free ports)
db-up:
    ./scripts/test-db-up.sh

# Tier 2: stop Docker databases
db-down:
    docker compose -f docker-compose.test.yml down

# Tier 2: run tier 1 + 2 tests (Docker databases must be running)
test-docker: db-up
    @set -a && [ -f .test-ports.env ] && . ./.test-ports.env; set +a; \
    cargo test --test dialect_tests -- --include-ignored

# Tier 3: refresh BigQuery access token
bq-refresh:
    sed -i '' "s|^BIGQUERY_ACCESS_TOKEN=.*|BIGQUERY_ACCESS_TOKEN=$$(gcloud auth print-access-token)|" .env

# Tier 3: run Snowflake tests
test-snowflake:
    cargo test --test dialect_tests -- --include-ignored snowflake

# Tier 3: run BigQuery tests (refreshes token first)
test-bigquery: bq-refresh
    cargo test --test dialect_tests -- --include-ignored bigquery

# Tier 2: run ClickHouse tests (Docker must be running)
test-clickhouse: db-up
    @set -a && [ -f .test-ports.env ] && . ./.test-ports.env; set +a; \
    cargo test --test dialect_tests -- --include-ignored clickhouse

# Tier 1: run DuckDB local tests
test-duckdb:
    cargo test --test dialect_tests -- duckdb_local

# Tier 1: run SQLite local tests
test-sqlite:
    cargo test --test dialect_tests -- sqlite_local

# Tier 3: run MotherDuck tests
test-motherduck:
    cargo test --test dialect_tests -- --include-ignored motherduck

# Tier 3: run all cloud warehouse tests
test-cloud: bq-refresh
    cargo test --test dialect_tests -- --include-ignored tier3

# Compatibility: clone real-world dbt repos and test airform against them
test-compat:
    cargo test --test compat_tests -- --include-ignored --nocapture compat_report_all

# Compatibility: run a single repo (e.g. just test-compat-one jaffle_shop)
test-compat-one name:
    cargo test --test compat_tests -- --include-ignored --nocapture {{name}}

# All tiers
test-all: db-up bq-refresh
    @set -a && [ -f .test-ports.env ] && . ./.test-ports.env; set +a; \
    cargo test --test dialect_tests -- --include-ignored

# ── Validate ─────────────────────────────────────────────

# Run clippy lints
lint:
    cargo clippy -- -D warnings

# Check formatting
fmt-check:
    cargo fmt -- --check

# Format code
fmt:
    cargo fmt

# ── Benchmarks ───────────────────────────────────────────

# Run compilation benchmarks
bench:
    cargo bench

# ── Utilities ────────────────────────────────────────────

# Clean build artifacts
clean:
    cargo clean
