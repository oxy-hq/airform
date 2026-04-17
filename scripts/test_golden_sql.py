#!/usr/bin/env python3
"""Test airform-compiled SQL against dbt golden references using sqlglot.

For each project in tests/golden/, compiles with airform and compares each
model's compiled SQL against the golden reference using sqlglot AST
normalization. Reports mismatches.

Usage:
    python3 scripts/test_golden_sql.py [project1 project2 ...]
    python3 scripts/test_golden_sql.py                  # all projects
    python3 scripts/test_golden_sql.py jira             # single project
    python3 scripts/test_golden_sql.py jira --model int_jira__issue_users  # single model
    python3 scripts/test_golden_sql.py --verbose        # show diffs
    python3 scripts/test_golden_sql.py --no-build       # skip cargo build

Results are saved to tests/golden-results.json after each run.

Prerequisites:
    cargo build -p airform   # builds target/debug/airform (done automatically)
    pip install sqlglot       # SQL normalization library
"""

import argparse
import difflib
import json
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import sqlglot

ROOT = Path(__file__).resolve().parent.parent
COMPAT_DIR = ROOT / "tests" / "compat-projects"
GOLDEN_DIR = ROOT / "tests" / "golden"
AIRFORM_BIN = ROOT / "target" / "debug" / "airform"
RESULTS_FILE = ROOT / "tests" / "golden-results.json"


def strip_database_prefix(sql: str) -> str:
    """Strip 3-part database.schema.table refs down to 2-part schema.table.

    dbt produces: "project"."schema"."table" or project.schema.table
    airform produces: schema.table
    These are semantically equivalent for our purposes.
    """
    # Match quoted 3-part: "db"."schema"."table" -> schema.table
    sql = re.sub(r'"[^"]+"\s*\.\s*"([^"]+)"\s*\.\s*"([^"]+)"', r'\1.\2', sql)
    # Match unquoted 3-part: db.schema.table -> schema.table
    sql = re.sub(r'\b(\w+)\.(\w+)\.(\w+)\b', r'\2.\3', sql)
    # Strip remaining double quotes around identifiers (normalize quoting)
    sql = re.sub(r'"(\w+)"', r'\1', sql)
    return sql


def has_inlined_ctes(sql: str) -> bool:
    """Check if SQL contains dbt-inlined ephemeral CTEs."""
    return "__dbt__cte__" in sql


def is_compile_time_fallback(sql: str) -> bool:
    """Check if SQL is a compile-time fallback (no real DB connection).

    Both dbt and airform produce dummy SQL for models that need to query
    the database at compile time (e.g., fivetran_utils.union_data, star()).
    These are expected to differ and should be skipped.
    """
    markers = [
        "CAST(NULL AS TEXT) AS _dbt_source_relation LIMIT 0",
        "No columns were returned",
        "This model is only necessary",
    ]
    return any(m in sql for m in markers)


def normalize_type_aliases(sql: str) -> str:
    """Normalize equivalent SQL type names and functions."""
    # FLOAT/REAL -> DOUBLE (all equivalent float types)
    sql = re.sub(r'\bFLOAT\b', 'DOUBLE', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bREAL\b', 'DOUBLE', sql, flags=re.IGNORECASE)
    # NOW() -> CURRENT_TIMESTAMP (equivalent)
    sql = re.sub(r'\bNOW\(\)', 'CURRENT_TIMESTAMP', sql, flags=re.IGNORECASE)
    # Normalize DECIMAL precision: DECIMAL(28,6) and DECIMAL(18,3) are both "numeric"
    sql = re.sub(r'DECIMAL\(\d+,\s*\d+\)', 'DECIMAL', sql, flags=re.IGNORECASE)
    # Normalize INTERVAL syntax: various forms -> INTERVAL 'N' UNIT
    # dbt: INTERVAL (1) DAY or INTERVAL (-1) DAY
    # airform: INTERVAL '1' day or INTERVAL '-1' day
    sql = re.sub(r"INTERVAL\s*\(\s*(-?\d+)\s*\)\s*(\w+)", r"INTERVAL '\1' \2", sql, flags=re.IGNORECASE)
    # TIMESTAMPADD(unit, N, expr) -> expr + INTERVAL 'N' UNIT
    sql = re.sub(r"TIMESTAMPADD\(\s*(\w+)\s*,\s*(-?\d+)\s*,\s*([^)]+)\)",
                 r"\3 + INTERVAL '\2' \1", sql, flags=re.IGNORECASE)
    # Normalize INTERVAL arithmetic: ((INTERVAL '1' UNIT) * (N)) -> INTERVAL 'N' UNIT
    sql = re.sub(
        r"\(\(INTERVAL\s+'1'\s+(\w+)\)\s*\*\s*\((-?\d+)\)\)",
        r"INTERVAL '\2' \1", sql, flags=re.IGNORECASE
    )
    # Normalize STR_SPLIT(expr, delim)[N] -> SPLIT_PART(expr, delim, N)
    sql = re.sub(r'STR_SPLIT\(([^,]+),\s*([^)]+)\)\[(\d+)\]',
                 r'SPLIT_PART(\1, \2, \3)', sql, flags=re.IGNORECASE)
    # Normalize MD5(CAST(expr AS TEXT/VARCHAR)) -> MD5(expr)
    sql = re.sub(r'\bMD5\(CAST\((.+?)\s+AS\s+(?:TEXT|VARCHAR)\)\)', r'MD5(\1)', sql, flags=re.IGNORECASE)
    return sql


def strip_redundant_timestamp_casts(sql: str) -> str:
    """Strip CAST(... AS TIMESTAMP) wrappers, keeping the inner expression.

    Uses balanced parenthesis matching to handle arbitrary nesting depth.
    """
    cast_re = re.compile(r'\bCAST\s*\(', re.IGNORECASE)
    as_ts_re = re.compile(r'\s+AS\s+TIMESTAMP\s*$', re.IGNORECASE)
    changed = True
    while changed:
        changed = False
        m = cast_re.search(sql)
        while m:
            start = m.start()
            # Find balanced closing paren for CAST(
            depth = 1
            i = m.end()
            while i < len(sql) and depth > 0:
                if sql[i] == '(':
                    depth += 1
                elif sql[i] == ')':
                    depth -= 1
                i += 1
            if depth != 0:
                m = cast_re.search(sql, m.end())
                continue
            # i points just past the closing ')'
            inner = sql[m.end():i - 1]
            # Check if inner ends with ' AS TIMESTAMP'
            ts_match = as_ts_re.search(inner)
            if ts_match and ts_match.end() == len(inner):
                expr = inner[:ts_match.start()]
                sql = sql[:start] + expr + sql[i:]
                changed = True
                break
            m = cast_re.search(sql, m.end())
    return sql


def normalize_sql(sql: str, dialect: str = "duckdb") -> str:
    """Normalize SQL using sqlglot for comparison."""
    sql = sql.strip()
    if not sql:
        return ""

    sql = strip_database_prefix(sql)
    sql = normalize_type_aliases(sql)

    try:
        parsed = sqlglot.transpile(sql, read=dialect, write=dialect, pretty=True)
        result = "\n\n".join(parsed).strip()
        result = strip_redundant_timestamp_casts(result)
        result = normalize_type_aliases(result)
        result = re.sub(r'\s+', ' ', result).strip()
        result = re.sub(r'\(\s+', '(', result)
        result = re.sub(r'\s+\)', ')', result)
        return result
    except Exception:
        normalized = re.sub(r'\s+', ' ', sql).strip()
        return normalized


def sql_equivalent(sql_a: str, sql_b: str, dialect: str = "duckdb") -> bool:
    """Check if two SQL statements are semantically equivalent using sqlglot."""
    a = sql_a.strip()
    b = sql_b.strip()

    if not a and not b:
        return True
    if not a or not b:
        return False
    if a == b:
        return True

    a = strip_database_prefix(a)
    b = strip_database_prefix(b)
    a = normalize_type_aliases(a)
    b = normalize_type_aliases(b)

    if a == b:
        return True

    norm_a = normalize_sql(a, dialect)
    norm_b = normalize_sql(b, dialect)

    if norm_a == norm_b:
        return True
    if norm_a.lower() == norm_b.lower():
        return True

    return False


def build_airform(force: bool = False) -> bool:
    """Build the airform debug binary. Returns True on success."""
    if not force and AIRFORM_BIN.exists():
        return True

    print("Building airform (cargo build -p airform)...")
    result = subprocess.run(
        ["cargo", "build", "-p", "airform"],
        capture_output=True,
        text=True,
        cwd=str(ROOT),
        timeout=120,
    )
    if result.returncode != 0:
        print(f"Build failed:\n{result.stderr}", file=sys.stderr)
        return False
    return True


def compile_with_airform(project_dir: Path) -> bool:
    """Compile a project with airform. Returns True on success."""
    result = subprocess.run(
        [str(AIRFORM_BIN), "compile", "--project-dir", str(project_dir)],
        capture_output=True,
        text=True,
        timeout=600,
    )
    return result.returncode == 0


def collect_airform_compiled(project_dir: Path) -> dict[str, str]:
    """Collect airform-compiled SQL files.

    When duplicates exist (same stem in different dirs), prefers the
    most recently modified file.
    """
    compiled_dir = project_dir / "target" / "compiled"
    if not compiled_dir.exists():
        return {}

    results = {}
    result_mtimes = {}
    for sql_file in compiled_dir.rglob("*.sql"):
        model_name = sql_file.stem
        content = sql_file.read_text().strip()
        if not content:
            continue
        mtime = sql_file.stat().st_mtime
        if model_name in results:
            if mtime > result_mtimes[model_name]:
                results[model_name] = content
                result_mtimes[model_name] = mtime
        else:
            results[model_name] = content
            result_mtimes[model_name] = mtime
    return results


def test_project(
    name: str,
    verbose: bool = False,
    model_filter: list[str] | None = None,
) -> tuple[int, int, int, int, list[str], list[dict]]:
    """Test one project.

    Returns (total, passed, failed, skipped, error_messages, model_results).
    """
    golden_expected = GOLDEN_DIR / name / "expected"
    project_dir = COMPAT_DIR / name

    if not golden_expected.exists():
        return 0, 0, 0, 0, [f"No golden references for {name}"], []
    if not project_dir.exists():
        return 0, 0, 0, 0, [f"No compat project for {name}"], []

    if not compile_with_airform(project_dir):
        return 0, 0, 0, 0, [f"airform compile failed for {name}"], []

    airform_compiled = collect_airform_compiled(project_dir)

    total = 0
    passed = 0
    failed = 0
    skipped = 0
    errors = []
    model_results = []

    for golden_file in sorted(golden_expected.glob("*.sql")):
        model_name = golden_file.stem

        # Skip schema test files
        if model_name.startswith(("not_null_", "unique_", "accepted_values_",
                                   "relationships_", "dbt_utils_", "dbt_expectations_")):
            continue

        # Apply model filter if specified
        if model_filter and model_name not in model_filter:
            continue

        golden_sql = golden_file.read_text().strip()
        airform_sql = airform_compiled.get(model_name, "").strip()

        # Skip ephemeral CTE models
        if has_inlined_ctes(golden_sql) or has_inlined_ctes(airform_sql):
            continue

        # Skip compile-time fallback models (both sides produce dummy SQL)
        if is_compile_time_fallback(golden_sql) or is_compile_time_fallback(airform_sql):
            continue

        if not airform_sql:
            skipped += 1
            if verbose:
                errors.append(f"  SKIP: {model_name} (not compiled by airform)")
            model_results.append({"model": model_name, "status": "skipped"})
            continue

        total += 1

        if sql_equivalent(golden_sql, airform_sql):
            passed += 1
            model_results.append({"model": model_name, "status": "pass"})
        else:
            failed += 1
            msg = f"  MISMATCH: {model_name}"
            if verbose:
                golden_norm = normalize_sql(golden_sql)
                airform_norm = normalize_sql(airform_sql)
                diff = difflib.unified_diff(
                    golden_norm.splitlines(),
                    airform_norm.splitlines(),
                    fromfile=f"dbt/{model_name}.sql",
                    tofile=f"airform/{model_name}.sql",
                    lineterm="",
                )
                diff_lines = list(diff)
                if diff_lines:
                    msg += "\n" + "\n".join(diff_lines[:30])
                    if len(diff_lines) > 30:
                        msg += f"\n    ... ({len(diff_lines) - 30} more lines)"
            errors.append(msg)
            model_results.append({"model": model_name, "status": "fail"})

    return total, passed, failed, skipped, errors, model_results


def save_results(project_results: list[dict], grand_total: int, grand_passed: int,
                 grand_failed: int, grand_skipped: int) -> None:
    """Save results to tests/golden-results.json."""
    results = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "summary": {
            "total": grand_total,
            "passed": grand_passed,
            "failed": grand_failed,
            "skipped": grand_skipped,
            "pass_rate": round(grand_passed / grand_total * 100, 1) if grand_total else 0,
        },
        "projects": project_results,
    }
    RESULTS_FILE.write_text(json.dumps(results, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(
        description="Test airform SQL against dbt golden references",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""examples:
  %(prog)s                          # test all projects
  %(prog)s jira                     # test one project
  %(prog)s jira mixpanel            # test multiple projects
  %(prog)s jira -m int_jira__issue_users  # test one model
  %(prog)s -v                       # show diffs for mismatches
  %(prog)s --no-build               # skip cargo build step
""",
    )
    parser.add_argument("projects", nargs="*", help="Projects to test (default: all)")
    parser.add_argument("--model", "-m", action="append", dest="models",
                        help="Filter to specific model(s) by name (repeatable)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show diffs for mismatches")
    parser.add_argument("--no-build", action="store_true", help="Skip cargo build step")
    parser.add_argument("--rebuild", action="store_true", help="Force rebuild even if binary exists")
    args = parser.parse_args()

    # Build binary
    if not args.no_build:
        if not build_airform(force=args.rebuild):
            sys.exit(1)
    elif not AIRFORM_BIN.exists():
        print(f"Error: {AIRFORM_BIN} not found. Run 'cargo build -p airform' first or remove --no-build.",
              file=sys.stderr)
        sys.exit(1)

    if args.projects:
        projects = args.projects
    else:
        projects = sorted(
            d.name for d in GOLDEN_DIR.iterdir()
            if d.is_dir() and (d / "expected").exists()
        ) if GOLDEN_DIR.exists() else []

    if not projects:
        print("No golden test projects found. Run generate_golden_sql.py first.")
        sys.exit(1)

    grand_total = 0
    grand_passed = 0
    grand_failed = 0
    grand_skipped = 0
    all_project_results = []

    start = time.time()

    for name in projects:
        total, passed, failed, skipped, errors, model_results = test_project(
            name, verbose=args.verbose, model_filter=args.models
        )
        grand_total += total
        grand_passed += passed
        grand_failed += failed
        grand_skipped += skipped

        project_data = {
            "name": name,
            "total": total,
            "passed": passed,
            "failed": failed,
            "skipped": skipped,
            "models": model_results,
        }
        all_project_results.append(project_data)

        if total > 0 or skipped > 0:
            status = "PASS" if failed == 0 else "FAIL"
            pct = passed / total * 100 if total > 0 else 0
            skip_info = f" ({skipped} skipped)" if skipped > 0 else ""
            print(f"{status:4s} {name:40s} {passed:4d}/{total:4d} ({pct:.0f}%){skip_info}")
            for err in errors[:5]:
                print(err)
            if len(errors) > 5:
                print(f"    ... and {len(errors) - 5} more")

    elapsed = time.time() - start

    # Summary
    print(f"\n{'='*60}")
    if grand_total > 0:
        pct = grand_passed / grand_total * 100
        print(f"TOTAL: {grand_passed}/{grand_total} compiled models match ({pct:.1f}%)")
        if grand_skipped > 0:
            print(f"SKIPPED: {grand_skipped} models not compiled by airform")
        perfect = sum(1 for p in all_project_results if p["failed"] == 0 and p["total"] > 0)
        tested = sum(1 for p in all_project_results if p["total"] > 0)
        print(f"PROJECTS: {perfect}/{tested} perfect")
    else:
        print("No models tested.")
    print(f"Elapsed: {elapsed:.1f}s")
    print(f"{'='*60}")

    # Save results
    save_results(all_project_results, grand_total, grand_passed, grand_failed, grand_skipped)
    print(f"Results saved to {RESULTS_FILE.relative_to(ROOT)}")

    sys.exit(0 if grand_failed == 0 else 1)


if __name__ == "__main__":
    main()
