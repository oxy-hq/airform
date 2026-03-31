#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# run_benchmark.sh -- Compare airform compile against dbt and sqlmesh
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

EXAMPLES=("jaffle-shop" "ecommerce-analytics" "large-scale" "scale-1000" "scale-10000")
WARMUP=2
RUNS=10

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

has() { command -v "$1" &>/dev/null; }

separator() {
    printf '\n%s\n' "$(printf '=%.0s' {1..70})"
}

header() {
    separator
    printf '  %s\n' "$1"
    separator
}

# Portable millisecond timer (works on macOS and Linux)
now_ms() {
    python3 -c 'import time; print(int(time.time()*1000))'
}

time_cmd() {
    local label="$1"; shift
    local cmd="$1"

    if has hyperfine; then
        hyperfine --warmup "$WARMUP" --runs "$RUNS" --style basic "$cmd"
        return
    fi

    # Check if command works at all first
    echo "[$label] verifying command..."
    if ! eval "$cmd" >/dev/null 2>/dev/null; then
        echo "  SKIPPED: command failed"
        echo "  Try running manually: $cmd"
        return
    fi

    echo "[$label] (using built-in time, $RUNS runs)"
    local total=0
    for i in $(seq 1 "$RUNS"); do
        local start end elapsed
        start=$(now_ms)
        eval "$cmd" >/dev/null 2>/dev/null
        end=$(now_ms)
        elapsed=$(( end - start ))
        total=$(( total + elapsed ))
    done
    local avg_ms=$(( total / RUNS ))
    echo "  Mean: ${avg_ms} ms  ($RUNS runs)"
}

# ---------------------------------------------------------------------------
# Build airform (release mode)
# ---------------------------------------------------------------------------

header "Building airform (release)"
cargo build --release --manifest-path "$REPO_ROOT/Cargo.toml" -p airform 2>&1
AIRFORM="$REPO_ROOT/target/release/airform"

if [ ! -f "$AIRFORM" ]; then
    echo "ERROR: airform binary not found at $AIRFORM"
    exit 1
fi

# ---------------------------------------------------------------------------
# Benchmark airform
# ---------------------------------------------------------------------------

header "Benchmarking airform compile"

for example in "${EXAMPLES[@]}"; do
    example_dir="$REPO_ROOT/examples/$example"
    if [ ! -d "$example_dir" ]; then
        echo "Skipping $example: directory not found"
        continue
    fi
    echo ""
    echo "--- $example ---"
    time_cmd "airform/$example" "$AIRFORM compile --project-dir $example_dir --target datafusion"
done

# ---------------------------------------------------------------------------
# Benchmark dbt (if installed)
# ---------------------------------------------------------------------------

if has dbt; then
    header "Benchmarking dbt compile"
    echo ""
    echo "NOTE: dbt needs a compatible adapter (e.g. dbt-duckdb) and a valid"
    echo "profiles.yml. Our examples use a 'datafusion' adapter which dbt does"
    echo "not support. If benchmarks fail, set up a dbt-duckdb profile."
    echo ""

    for example in "${EXAMPLES[@]}"; do
        example_dir="$REPO_ROOT/examples/$example"
        if [ ! -d "$example_dir" ]; then
            continue
        fi
        echo "--- $example ---"
        time_cmd "dbt/$example" \
            "dbt compile --project-dir $example_dir --profiles-dir $example_dir --target duckdb --no-partial-parse"
    done
else
    separator
    echo "  dbt not found -- skipping dbt benchmarks"
    echo "  Install: pip install dbt-core dbt-duckdb"
    separator
fi

# ---------------------------------------------------------------------------
# Benchmark sqlmesh (if installed)
# ---------------------------------------------------------------------------

if has sqlmesh; then
    header "Benchmarking sqlmesh"
    echo ""
    echo "NOTE: sqlmesh requires its own config.yaml to read dbt projects."
    echo "If benchmarks fail, add a config.yaml to each example directory."
    echo ""

    for example in "${EXAMPLES[@]}"; do
        example_dir="$REPO_ROOT/examples/$example"
        if [ ! -d "$example_dir" ]; then
            continue
        fi
        echo "--- $example ---"
        # Use 'sqlmesh render' to measure load+parse+compile time.
        # Most of sqlmesh's time is spent loading the context, so rendering
        # one model captures the compile overhead fairly.
        first_model=$(ls "$example_dir/models/staging/"*.sql 2>/dev/null | head -1 | xargs basename | sed 's/.sql//')
        if [ -z "$first_model" ]; then
            echo "  SKIPPED: no staging models found"
            continue
        fi
        time_cmd "sqlmesh/$example" \
            "cd $example_dir && sqlmesh render main.$first_model"
    done
else
    separator
    echo "  sqlmesh not found -- skipping sqlmesh benchmarks"
    echo "  Install: pip install 'sqlmesh[dbt]'"
    separator
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

header "Summary"
echo ""
echo "Tool availability:"
echo "  airform : $AIRFORM"
has dbt      && echo "  dbt     : $(which dbt)" || echo "  dbt     : not installed"
has sqlmesh  && echo "  sqlmesh : $(which sqlmesh)" || echo "  sqlmesh : not installed"
echo ""
echo "Install hyperfine for better benchmarks: brew install hyperfine"
echo ""
echo "For Rust-internal microbenchmarks run:"
echo "  cargo bench --manifest-path $REPO_ROOT/Cargo.toml"
echo ""
