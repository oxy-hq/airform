#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# run_benchmark.sh -- Compare airform compile against dbt and sqlmesh
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

EXAMPLES=("jaffle-shop" "ecommerce-analytics")
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

time_cmd() {
    # Use hyperfine if available, otherwise fall back to time
    local label="$1"; shift
    if has hyperfine; then
        hyperfine --warmup "$WARMUP" --runs "$RUNS" --style basic "$@"
    else
        echo "[$label] (using built-in time, $RUNS runs)"
        local total=0
        for i in $(seq 1 "$RUNS"); do
            local start end elapsed
            start=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')
            eval "$@" >/dev/null 2>&1
            end=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')
            elapsed=$(( (end - start) ))
            total=$(( total + elapsed ))
        done
        local avg_ms=$(( total / RUNS / 1000000 ))
        echo "  Mean: ${avg_ms} ms  ($RUNS runs)"
    fi
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
    time_cmd "airform/$example" "$AIRFORM compile --project-dir $example_dir"
done

# ---------------------------------------------------------------------------
# Benchmark dbt (if installed)
# ---------------------------------------------------------------------------

if has dbt; then
    header "Benchmarking dbt compile"

    for example in "${EXAMPLES[@]}"; do
        example_dir="$REPO_ROOT/examples/$example"
        if [ ! -d "$example_dir" ]; then
            continue
        fi
        echo ""
        echo "--- $example ---"
        time_cmd "dbt/$example" "dbt compile --project-dir $example_dir"
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
    header "Benchmarking sqlmesh (dbt project reader)"

    for example in "${EXAMPLES[@]}"; do
        example_dir="$REPO_ROOT/examples/$example"
        if [ ! -d "$example_dir" ]; then
            continue
        fi
        echo ""
        echo "--- $example ---"
        # sqlmesh can read dbt projects via its dbt integration.
        # Use 'sqlmesh --paths <dir> plan --no-prompts --skip-tests --no-auto-categorization'
        # with a DuckDB gateway config. If that fails, fall back to 'sqlmesh render'.
        if time_cmd "sqlmesh/$example" \
            "cd $example_dir && sqlmesh --paths . plan --no-prompts --skip-tests --no-auto-categorization 2>/dev/null" 2>/dev/null; then
            :
        else
            echo "  sqlmesh could not parse this project (dbt project may need a config.yaml)"
            echo "  To benchmark sqlmesh, create a config.yaml in the example directory."
        fi
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
echo "For more detailed Rust-internal benchmarks run:"
echo "  cargo bench --manifest-path $REPO_ROOT/Cargo.toml"
echo ""
echo "For criterion HTML reports see:"
echo "  $REPO_ROOT/target/criterion/report/index.html"
