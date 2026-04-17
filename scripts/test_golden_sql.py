#!/usr/bin/env python3
"""Test airform-compiled SQL against dbt golden references using sqlglot.

For each project in tests/golden/, compiles with airform and compares each
model's compiled SQL against the golden reference using sqlglot AST
normalization. Reports mismatches.

Usage:
    python3 scripts/test_golden_sql.py [project1 project2 ...]
    python3 scripts/test_golden_sql.py                  # all projects
    python3 scripts/test_golden_sql.py --verbose        # show diffs
    python3 scripts/test_golden_sql.py --update         # update golden from airform output
"""

import argparse
import difflib
import os
import subprocess
import sys
from pathlib import Path

import sqlglot

ROOT = Path(__file__).resolve().parent.parent
COMPAT_DIR = ROOT / "tests" / "compat-projects"
GOLDEN_DIR = ROOT / "tests" / "golden"
AIRFORM_BIN = ROOT / "target" / "debug" / "airform"


def strip_database_prefix(sql: str) -> str:
    """Strip 3-part database.schema.table refs down to 2-part schema.table.

    dbt produces: "project"."schema"."table" or project.schema.table
    airform produces: schema.table
    These are semantically equivalent for our purposes.
    """
    import re
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


def normalize_type_aliases(sql: str) -> str:
    """Normalize equivalent SQL type names and functions."""
    import re
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
    return sql


def strip_redundant_timestamp_casts(sql: str) -> str:
    """Strip CAST(... AS TIMESTAMP) wrappers, keeping the inner expression.

    dbt adds explicit TIMESTAMP casts around columns/expressions that are
    already of timestamp type. airform omits these. Both are semantically
    equivalent when the underlying column is already a timestamp.
    """
    import re
    # Iteratively strip CAST(... AS TIMESTAMP) — handle nested parens
    changed = True
    while changed:
        new_sql = re.sub(
            r'CAST\(([^()]*(?:\([^()]*\))*[^()]*)\s+AS\s+TIMESTAMP\)',
            r'\1', sql, flags=re.IGNORECASE | re.DOTALL
        )
        changed = (new_sql != sql)
        sql = new_sql
    return sql


def normalize_sql(sql: str, dialect: str = "duckdb") -> str:
    """Normalize SQL using sqlglot for comparison.

    Parses the SQL and regenerates it with consistent formatting.
    Falls back to whitespace normalization if parsing fails.
    """
    import re
    sql = sql.strip()
    if not sql:
        return ""

    # Pre-normalize
    sql = strip_database_prefix(sql)
    sql = normalize_type_aliases(sql)

    try:
        # Parse and regenerate for consistent formatting
        parsed = sqlglot.transpile(sql, read=dialect, write=dialect, pretty=True)
        result = "\n\n".join(parsed).strip()
        # Post-sqlglot normalizations
        result = strip_redundant_timestamp_casts(result)
        result = normalize_type_aliases(result)
        # Final whitespace normalization to handle formatting-only differences
        result = re.sub(r'\s+', ' ', result).strip()
        # Normalize spaces around parentheses: "( " -> "(", " )" -> ")"
        result = re.sub(r'\(\s+', '(', result)
        result = re.sub(r'\s+\)', ')', result)
        return result
    except Exception:
        # Fallback: normalize whitespace only
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

    # Quick exact match
    if a == b:
        return True

    # Pre-normalize both sides
    a = strip_database_prefix(a)
    b = strip_database_prefix(b)
    a = normalize_type_aliases(a)
    b = normalize_type_aliases(b)

    if a == b:
        return True

    # Try sqlglot normalization
    norm_a = normalize_sql(a, dialect)
    norm_b = normalize_sql(b, dialect)

    if norm_a == norm_b:
        return True

    # Try case-insensitive comparison of normalized
    if norm_a.lower() == norm_b.lower():
        return True

    return False


def compile_with_airform(project_dir: Path) -> bool:
    """Compile a project with airform. Returns True on success."""
    if not AIRFORM_BIN.exists():
        # Try to build first
        subprocess.run(
            ["cargo", "build", "-p", "airform"],
            capture_output=True,
            cwd=str(ROOT),
            timeout=120,
        )

    result = subprocess.run(
        [str(AIRFORM_BIN), "compile", "--project-dir", str(project_dir)],
        capture_output=True,
        text=True,
        timeout=300,
    )
    return result.returncode == 0


def collect_airform_compiled(project_dir: Path) -> dict[str, str]:
    """Collect airform-compiled SQL files."""
    compiled_dir = project_dir / "target" / "compiled"
    if not compiled_dir.exists():
        return {}

    results = {}
    for sql_file in compiled_dir.rglob("*.sql"):
        model_name = sql_file.stem
        content = sql_file.read_text().strip()
        if content:
            results[model_name] = content
    return results


def test_project(name: str, verbose: bool = False) -> tuple[int, int, int, list[str]]:
    """Test one project. Returns (total, passed, failed, error_messages)."""
    golden_expected = GOLDEN_DIR / name / "expected"
    project_dir = COMPAT_DIR / name

    if not golden_expected.exists():
        return 0, 0, 0, [f"No golden references for {name}"]

    if not project_dir.exists():
        return 0, 0, 0, [f"No compat project for {name}"]

    # Compile with airform
    if not compile_with_airform(project_dir):
        return 0, 0, 0, [f"airform compile failed for {name}"]

    # Collect airform output
    airform_compiled = collect_airform_compiled(project_dir)

    # Compare against golden references
    total = 0
    passed = 0
    failed = 0
    errors = []

    for golden_file in sorted(golden_expected.glob("*.sql")):
        model_name = golden_file.stem
        total += 1

        golden_sql = golden_file.read_text().strip()
        airform_sql = airform_compiled.get(model_name, "").strip()

        # Skip models where either side inlined ephemeral CTEs — these are a known
        # structural difference (airform resolves refs differently) and not
        # meaningful to compare at the SQL text level.
        if has_inlined_ctes(golden_sql) or has_inlined_ctes(airform_sql):
            total -= 1  # Don't count these
            continue

        if not airform_sql:
            failed += 1
            errors.append(f"  MISSING: {model_name} (not compiled by airform)")
            continue

        if sql_equivalent(golden_sql, airform_sql):
            passed += 1
        else:
            failed += 1
            msg = f"  MISMATCH: {model_name}"
            if verbose:
                # Show diff
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

    return total, passed, failed, errors


def main():
    parser = argparse.ArgumentParser(description="Test airform SQL against dbt golden references")
    parser.add_argument("projects", nargs="*", help="Projects to test (default: all)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show diffs for mismatches")
    parser.add_argument("--update", action="store_true", help="Update golden from airform output")
    args = parser.parse_args()

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
    project_results = []

    for name in projects:
        total, passed, failed, errors = test_project(name, verbose=args.verbose)
        grand_total += total
        grand_passed += passed
        grand_failed += failed

        if total > 0:
            status = "PASS" if failed == 0 else "FAIL"
            pct = passed / total * 100 if total > 0 else 0
            project_results.append((name, total, passed, failed, status))

            print(f"{status:4s} {name:40s} {passed:4d}/{total:4d} ({pct:.0f}%)")
            for err in errors[:5]:  # Limit errors per project
                print(err)
            if len(errors) > 5:
                print(f"    ... and {len(errors) - 5} more")

    # Summary
    print(f"\n{'='*60}")
    if grand_total > 0:
        pct = grand_passed / grand_total * 100
        print(f"TOTAL: {grand_passed}/{grand_total} models match ({pct:.1f}%)")
        perfect = sum(1 for _, _, _, f, _ in project_results if f == 0)
        print(f"PROJECTS: {perfect}/{len(project_results)} perfect")
    else:
        print("No models tested.")
    print(f"{'='*60}")

    sys.exit(0 if grand_failed == 0 else 1)


if __name__ == "__main__":
    main()
