#!/usr/bin/env python3
"""Generate golden (dbt-compiled) SQL for compat test projects.

For each project in tests/compat-projects/, runs `dbt compile` and copies
the compiled SQL into tests/golden/<project>/expected/.

Usage:
    python3 scripts/generate_golden_sql.py [project1 project2 ...]
    python3 scripts/generate_golden_sql.py          # all projects
"""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COMPAT_DIR = ROOT / "tests" / "compat-projects"
GOLDEN_DIR = ROOT / "tests" / "golden"


def compile_project(project_dir: Path) -> bool:
    """Run dbt compile on a project. Returns True on success."""
    # Install deps if packages.yml exists and dbt_packages doesn't
    packages_yml = project_dir / "packages.yml"
    dbt_packages = project_dir / "dbt_packages"
    if packages_yml.exists() and not dbt_packages.exists():
        subprocess.run(
            ["dbt", "deps", "--project-dir", str(project_dir), "--profiles-dir", str(project_dir)],
            capture_output=True, text=True, cwd=str(project_dir), timeout=120,
        )

    result = subprocess.run(
        ["dbt", "compile", "--project-dir", str(project_dir), "--profiles-dir", str(project_dir)],
        capture_output=True,
        text=True,
        cwd=str(project_dir),
        timeout=120,
    )
    if result.returncode != 0:
        # Extract useful error from stderr
        err = result.stderr.strip()
        # Also check stdout for dbt error messages
        out = result.stdout.strip()
        msg = ""
        for line in (out + "\n" + err).splitlines():
            if "Error" in line or "error" in line:
                msg = line.strip()[:200]
                break
        if not msg:
            msg = err[:200] if err else "unknown error"
        print(f"  dbt compile failed: {msg}")
        return False
    return True


def collect_compiled_sql(project_dir: Path) -> dict[str, str]:
    """Collect compiled SQL files from dbt's target/compiled/ directory."""
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


def process_project(name: str) -> tuple[int, int]:
    """Process one project. Returns (total_models, compiled_models)."""
    project_dir = COMPAT_DIR / name
    if not (project_dir / "dbt_project.yml").exists():
        print(f"  SKIP: no dbt_project.yml")
        return 0, 0

    # Run dbt compile
    print(f"  Compiling with dbt...")
    if not compile_project(project_dir):
        return 0, 0

    # Collect compiled SQL
    compiled = collect_compiled_sql(project_dir)
    if not compiled:
        print(f"  SKIP: no compiled output")
        return 0, 0

    # Write golden files
    golden_dir = GOLDEN_DIR / name / "expected"
    golden_dir.mkdir(parents=True, exist_ok=True)

    for model_name, sql in compiled.items():
        (golden_dir / f"{model_name}.sql").write_text(sql + "\n")

    print(f"  Wrote {len(compiled)} golden SQL files")
    return len(compiled), len(compiled)


def main():
    projects = sys.argv[1:] if len(sys.argv) > 1 else sorted(
        d.name for d in COMPAT_DIR.iterdir()
        if d.is_dir() and (d / "dbt_project.yml").exists()
    )

    total_projects = 0
    total_models = 0
    failed = []

    for name in projects:
        print(f"\n{'='*60}")
        print(f"Project: {name}")
        print(f"{'='*60}")
        _, compiled = process_project(name)
        if compiled > 0:
            total_projects += 1
            total_models += compiled
        else:
            failed.append(name)

    print(f"\n{'='*60}")
    print(f"TOTAL: {total_models} golden SQL files across {total_projects} projects")
    if failed:
        print(f"FAILED ({len(failed)}): {', '.join(failed)}")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
