# Airform Benchmarks

This directory contains tooling for benchmarking airform's compilation pipeline and comparing it against dbt and sqlmesh.

## Rust Internal Benchmarks (Criterion)

Criterion benchmarks measure each stage of the internal pipeline individually:

| Benchmark group  | What it measures                                      |
|------------------|-------------------------------------------------------|
| `load`           | Loading project config, discovering models and macros |
| `parse`          | Parsing SQL files, extracting refs/sources            |
| `graph`          | Building the dependency DAG from the manifest         |
| `compile`        | Jinja rendering and ref/source resolution             |
| `full_pipeline`  | All stages end-to-end (load + parse + graph + compile)|

Each group runs against both `jaffle-shop` and `ecommerce-analytics` example projects.

### Running

```bash
# Run all criterion benchmarks
cargo bench

# Run a specific benchmark group
cargo bench -- load
cargo bench -- full_pipeline
```

### Output

- Console output shows per-iteration statistics (mean, std dev, throughput).
- HTML reports are generated at `target/criterion/report/index.html`.
- Subsequent runs automatically compare against the previous baseline and report regressions/improvements.

## CLI Comparison Benchmark

`run_benchmark.sh` compares wall-clock compile times across tools using [hyperfine](https://github.com/sharkdp/hyperfine) (with a fallback to the shell `time` builtin).

### Prerequisites

- **Required**: Rust toolchain (to build airform)
- **Recommended**: [hyperfine](https://github.com/sharkdp/hyperfine) (`brew install hyperfine` / `cargo install hyperfine`)
- **Optional**: `dbt` (`pip install dbt-core dbt-duckdb`)
- **Optional**: `sqlmesh` (`pip install sqlmesh`)

### Running

```bash
./benchmarks/run_benchmark.sh
```

The script will:

1. Build airform in release mode.
2. Run `airform compile` on each example project.
3. Run `dbt compile` on each example project (if dbt is installed).
4. Run `sqlmesh plan --dry-run` on each example project (if sqlmesh is installed).
5. Print a summary comparing the results.

### Interpreting Results

When using hyperfine, you will see output like:

```
Benchmark 1: airform compile --project-dir examples/jaffle-shop
  Time (mean +/- sigma):      12.3 ms +/-  1.1 ms    [User: 8.2 ms, System: 3.4 ms]
  Range (min ... max):        10.5 ms ... 15.2 ms    10 runs
```

Key metrics:
- **Mean**: Average execution time across all runs.
- **Sigma**: Standard deviation -- lower means more consistent.
- **Min/Max**: Best and worst observed times.

When comparing tools, focus on the mean time. Airform is expected to be significantly faster than dbt and sqlmesh for the compile/parse step due to its Rust implementation.
