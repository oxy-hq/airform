#!/usr/bin/env python3
"""Generate self-contained dbt projects from compat repos for execution testing.

For each repo in tests/compat/repos.json:
  1. Clone (or reuse cache) from GitHub
  2. Detect integration test structure (Fivetran seeds/, Snowplow data/, playbook data/)
  3. Assemble a self-contained project: models + macros + seeds
  4. Generate profiles.yml for DuckDB + DataFusion
  5. Write to tests/compat-projects/{name}/

Usage:
  python scripts/generate_compat_projects.py              # generate all
  python scripts/generate_compat_projects.py --repos shopify,stripe  # specific repos
  python scripts/generate_compat_projects.py --dry-run     # just show what would be done
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPOS_JSON = ROOT / "tests" / "compat" / "repos.json"
CACHE_DIR = ROOT / "target" / "compat-repos"
OUTPUT_DIR = ROOT / "tests" / "compat-projects"


def load_repos(filter_names=None):
    with open(REPOS_JSON) as f:
        repos = json.load(f)
    if filter_names:
        names = set(filter_names)
        repos = [r for r in repos if r["name"] in names]
    return repos


def clone_repo(repo_entry):
    """Clone repo if not already cached. Returns path to project root."""
    org_repo = repo_entry["repo"]
    repo_name = org_repo.split("/")[-1]
    repo_path = CACHE_DIR / repo_name

    if not repo_path.exists():
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        url = f"https://github.com/{org_repo}.git"
        print(f"  Cloning {url}...")
        subprocess.run(
            ["git", "clone", "--depth", "1", url, str(repo_path)],
            check=True,
            capture_output=True,
        )

    subdir = repo_entry.get("project_subdir")
    if subdir:
        return repo_path / subdir
    return repo_path


def detect_structure(repo_path):
    """Detect the integration test structure of a repo.

    Returns dict with:
      type: "fivetran" | "snowplow" | "playbook" | "subproject"
      int_tests_dir: Path to integration_tests/ or None
      seed_dir: Path to seed data directory
      seed_dir_name: "seeds" or "data" or "data/source"
      models_dir: Path to models/
      macros_dir: Path to macros/ or None
      dbt_project: Path to main dbt_project.yml
      int_dbt_project: Path to integration_tests/dbt_project.yml or None
    """
    int_tests = repo_path / "integration_tests"

    # Special case: dbt_artifacts uses integration_test_project
    if not int_tests.exists():
        int_tests = repo_path / "integration_test_project"

    if int_tests.exists() and int_tests.is_dir():
        # Has integration tests
        seed_dir = None
        seed_dir_name = None
        for candidate, name in [
            (int_tests / "seeds", "seeds"),
            (int_tests / "data" / "source", "data/source"),
            (int_tests / "data", "data"),
        ]:
            if candidate.exists() and candidate.is_dir():
                seed_dir = candidate
                seed_dir_name = name
                break

        # Determine if this is a Fivetran sub-project pattern
        int_dbt_project = int_tests / "dbt_project.yml"
        int_packages = int_tests / "packages.yml"

        # Check if integration_tests references parent via local: ../
        is_subproject = False
        if int_packages.exists():
            content = int_packages.read_text()
            if "local: ../" in content or "local: .." in content:
                is_subproject = True

        if is_subproject:
            return {
                "type": "fivetran",
                "int_tests_dir": int_tests,
                "seed_dir": seed_dir,
                "seed_dir_name": seed_dir_name or "seeds",
                "models_dir": repo_path / "models",
                "macros_dir": repo_path / "macros" if (repo_path / "macros").exists() else None,
                "dbt_project": repo_path / "dbt_project.yml",
                "int_dbt_project": int_dbt_project if int_dbt_project.exists() else None,
            }
        else:
            # Self-contained integration test project (like dbt_artifacts)
            return {
                "type": "subproject",
                "int_tests_dir": int_tests,
                "seed_dir": seed_dir,
                "seed_dir_name": seed_dir_name or "seeds",
                "models_dir": int_tests / "models" if (int_tests / "models").exists() else None,
                "macros_dir": int_tests / "macros" if (int_tests / "macros").exists() else None,
                "dbt_project": int_dbt_project if int_dbt_project.exists() else repo_path / "dbt_project.yml",
                "int_dbt_project": int_dbt_project if int_dbt_project.exists() else None,
            }
    else:
        # No integration tests - playbook-style with seeds in data/ or seeds/
        seed_dir = None
        seed_dir_name = None
        for candidate, name in [
            (repo_path / "seeds", "seeds"),
            (repo_path / "data", "data"),
        ]:
            if candidate.exists() and candidate.is_dir():
                seed_dir = candidate
                seed_dir_name = name
                break

        return {
            "type": "playbook",
            "int_tests_dir": None,
            "seed_dir": seed_dir,
            "seed_dir_name": seed_dir_name,
            "models_dir": repo_path / "models",
            "macros_dir": repo_path / "macros" if (repo_path / "macros").exists() else None,
            "dbt_project": repo_path / "dbt_project.yml",
            "int_dbt_project": None,
        }


def extract_project_name(dbt_project_path):
    """Extract project name from dbt_project.yml."""
    if not dbt_project_path or not dbt_project_path.exists():
        return "unknown"
    content = dbt_project_path.read_text()
    for line in content.splitlines():
        line = line.strip()
        if line.startswith("name:"):
            name = line.split(":", 1)[1].strip().strip("'\"")
            return name
    return "unknown"


def extract_profile_name(dbt_project_path):
    """Extract profile name from dbt_project.yml."""
    if not dbt_project_path or not dbt_project_path.exists():
        return None
    content = dbt_project_path.read_text()
    for line in content.splitlines():
        line = line.strip()
        if line.startswith("profile:"):
            return line.split(":", 1)[1].strip().strip("'\"")
    return None


def resolve_jinja_type(jinja_str):
    """Resolve Jinja column type expressions to DuckDB-compatible types."""
    if not isinstance(jinja_str, str):
        return str(jinja_str)

    s = jinja_str.strip()

    # Direct types
    if s in ("timestamp", "bigint", "float", "boolean", "varchar", "text", "integer", "date"):
        return s

    # Jinja conditionals - extract the else/default branch (usually the generic type)
    # Pattern: {%- if target.type == 'bigquery' -%} INT64 {%- else -%} bigint {%- endif -%}
    else_match = re.search(r'\{%-?\s*else\s*-?%\}\s*(\w+)', s)
    if else_match:
        return resolve_jinja_type(else_match.group(1))

    # Pattern: {{ 'string' if target.type in (...) else 'varchar' }}
    else_match2 = re.search(r"else\s+['\"](\w+)['\"]", s)
    if else_match2:
        return resolve_jinja_type(else_match2.group(1))

    # If it's a simple {{ ... }} with a type inside
    type_match = re.search(r"['\"](\w+)['\"]", s)
    if type_match:
        t = type_match.group(1)
        type_map = {
            "INT64": "bigint",
            "int64": "bigint",
            "FLOAT64": "float",
            "float64": "float",
            "STRING": "varchar",
            "string": "varchar",
            "BOOLEAN": "boolean",
            "TIMESTAMP": "timestamp",
            "DATE": "date",
        }
        return type_map.get(t, t)

    # Strip Jinja and return whatever is left
    cleaned = re.sub(r'\{[%{].*?[%}]\}', '', s).strip()
    return cleaned if cleaned else "varchar"


def render_dbt_jinja(content, extra_vars=None):
    """Render Jinja in dbt YAML/SQL content using a mock dbt context.

    Provides a mock `target`, `var()`, `env_var()`, `doc()`, etc. so that
    dbt_project.yml and source YAML files can be fully rendered to plain YAML.
    """
    import jinja2

    # Mock dbt context — start with any extra vars provided
    mock_vars = dict(extra_vars or {})

    # Pre-scan the raw content for *_identifier vars (e.g., sap_acdoca_identifier: sap_acdoca_data).
    # These are used by source() to resolve table identifiers, and they're often defined in the
    # same file as the source() calls that need them.
    for m in re.finditer(r'(\w+_identifier)\s*:\s*["\']?(\w+)["\']?', content):
        var_name, var_value = m.group(1), m.group(2)
        if var_name not in mock_vars:
            mock_vars[var_name] = var_value

    def var_fn(name, default=None):
        return mock_vars.get(name, default if default is not None else name)

    def env_var_fn(name, default=""):
        return os.environ.get(name, default)

    def doc_fn(name):
        return ""

    # Build a mock target object
    class MockTarget:
        type = "duckdb"
        name = "duckdb"
        database = "main"
        schema = "main"

    def source_fn(*args):
        """Resolve source() by looking up the identifier var.

        For source('sap', 'acdoca'), checks var('sap_acdoca_identifier', 'acdoca').
        Falls back to the table name if no identifier var is defined.
        """
        if len(args) < 2:
            return "__source__"
        source_name, table_name = args[0], args[1]
        # Try common identifier var patterns:
        #   {source}_{table}_identifier (e.g., sap_acdoca_identifier)
        #   {project_prefix}_{table}_identifier
        for prefix in [source_name, ""]:
            if prefix:
                id_var = f"{prefix}_{table_name}_identifier"
            else:
                id_var = f"{table_name}_identifier"
            if id_var in mock_vars:
                return mock_vars[id_var]
        return table_name

    env = jinja2.Environment(
        undefined=jinja2.Undefined,  # silently ignore undefined vars
    )
    env.globals["var"] = var_fn
    env.globals["env_var"] = env_var_fn
    env.globals["doc"] = doc_fn
    env.globals["target"] = MockTarget()
    env.globals["source"] = source_fn
    env.globals["ref"] = lambda *args: args[0] if args else "__ref__"
    env.globals["config"] = lambda **kwargs: ""
    env.globals["adapter"] = type("MockAdapter", (), {
        "dispatch": staticmethod(lambda *args, **kwargs: lambda: ""),
    })()
    env.globals["exceptions"] = type("MockExceptions", (), {
        "raise_compiler_error": staticmethod(lambda msg: ""),
    })()
    env.globals["log"] = lambda *args, **kwargs: ""
    env.globals["return"] = lambda *args: ""
    env.globals["modules"] = type("MockModules", (), {
        "re": re,
        "datetime": __import__("datetime"),
    })()

    try:
        template = env.from_string(content)
        return template.render()
    except Exception:
        # Fallback: strip Jinja with regex
        cleaned = re.sub(r'"[^"]*\{\{[^"]*\}\}[^"]*"', '"__jinja__"', content)
        cleaned = re.sub(r"'[^']*\{\{[^']*\}\}[^']*'", "'__jinja__'", cleaned)
        cleaned = re.sub(r'\{\{[^}]*\}\}', '__jinja__', cleaned)
        cleaned = re.sub(r'\{%-?[^%]*-?%\}', '', cleaned)
        return cleaned


def parse_yaml_with_jinja(content, extra_vars=None):
    """Render Jinja in YAML content, then parse as YAML."""
    import yaml

    rendered = render_dbt_jinja(content, extra_vars)
    try:
        return yaml.safe_load(rendered)
    except Exception:
        return None


def parse_int_dbt_project(path):
    """Parse integration_tests/dbt_project.yml to extract vars and seed column types.

    Returns:
      vars: dict of var overrides (flat + nested)
      seed_column_types: dict of {seed_name: {col: type}}
      schema_var_value: value of the *_schema var
    """
    if not path or not path.exists():
        return {}, {}, None

    content = path.read_text()
    data = parse_yaml_with_jinja(content)

    if not isinstance(data, dict):
        return {}, {}, None

    vars_section = data.get("vars", {}) or {}
    seeds_section = data.get("seeds", {}) or {}

    # Extract schema var (e.g., shopify_schema: shopify_integration_tests)
    schema_var_value = None
    flat_vars = {}
    for k, v in vars_section.items():
        if isinstance(v, str) and v != "__jinja__" and k.endswith("_schema"):
            schema_var_value = v
        if isinstance(v, dict):
            # Nested vars under package name
            for k2, v2 in v.items():
                if isinstance(v2, str) and v2 != "__jinja__":
                    flat_vars[k2] = v2
        elif isinstance(v, str) and v != "__jinja__":
            flat_vars[k] = v

    # Extract seed column types from the original content (regex-based)
    # because the Jinja in column_types is the actual type info we need
    seed_column_types = extract_seed_column_types(content)

    return flat_vars, seed_column_types, schema_var_value


def extract_seed_column_types(content):
    """Extract seed column types from dbt_project.yml using regex.

    Handles Jinja type expressions like:
      "{%- if target.type == 'bigquery' -%} INT64 {%- else -%} bigint {%- endif -%}"
    """
    result = {}

    # Find seeds: section
    seeds_match = re.search(r'^seeds:\s*\n((?:[ \t]+.*\n)*)', content, re.MULTILINE)
    if not seeds_match:
        return result

    seeds_block = seeds_match.group(1)

    # Find top-level +column_types (applies to all seeds in the package)
    top_types = {}
    # Find the first +column_types at any level
    top_ct_match = re.search(
        r'^\s+\+column_types:\s*\n((?:\s+\S.*\n)*)',
        seeds_block,
        re.MULTILINE
    )
    if top_ct_match:
        for line in top_ct_match.group(1).splitlines():
            line = line.strip()
            if not line or line.startswith("+") or line.startswith("#"):
                continue
            # Skip lines that look like SQL statements or YAML lists
            if line.startswith("-") or "update " in line.lower() or "select " in line.lower():
                continue
            if ":" in line:
                col, typ = line.split(":", 1)
                col = col.strip()
                typ = typ.strip().strip("'\"")
                if "{{" in col or "{{" in typ or len(col) > 50:
                    continue
                resolved = resolve_jinja_type(typ)
                if resolved and resolved != "__jinja__":
                    top_types[col] = resolved

    # Find per-seed +column_types sections
    # Pattern: seed_name:\n  +column_types:\n    col: type
    seed_pattern = re.compile(
        r'^(\s{4,8})(\w+):\s*\n'  # seed name at some indent
        r'(?:\1\s+\+\w+:.*\n)*'   # optional other + configs
        r'\1\s+\+column_types:\s*\n'  # +column_types header
        r'((?:\1\s{4,}\S.*\n)*)',  # column type lines
        re.MULTILINE
    )

    for m in seed_pattern.finditer(seeds_block):
        seed_name = m.group(2)
        if seed_name.startswith("+"):
            continue
        types = dict(top_types)  # inherit top-level
        for line in m.group(3).splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            # Skip lines that look like SQL statements or YAML lists
            if line.startswith("-") or "update " in line.lower() or "select " in line.lower():
                continue
            if ":" in line:
                col, typ = line.split(":", 1)
                col = col.strip()
                typ = typ.strip().strip("'\"")
                # Skip columns that look like Jinja rendering artifacts
                if "{{" in col or "{{" in typ or len(col) > 50:
                    continue
                resolved = resolve_jinja_type(typ)
                if resolved and resolved != "__jinja__":
                    types[col] = resolved
        if types:
            result[seed_name] = types

    return result


def copytree_ignore_pycache(src, dst):
    """Copy directory tree, ignoring __pycache__ and .git."""
    shutil.copytree(
        src, dst,
        ignore=shutil.ignore_patterns("__pycache__", ".git", "*.pyc", "__pycache__"),
        dirs_exist_ok=True,
    )


def assemble_fivetran_project(name, structure, repo_entry, output_dir):
    """Assemble a self-contained project for a Fivetran-style repo."""
    out = output_dir / name
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)

    pkg_name = extract_project_name(structure["dbt_project"])
    int_name = extract_project_name(structure["int_dbt_project"])

    # Copy models from parent
    if structure["models_dir"] and structure["models_dir"].exists():
        copytree_ignore_pycache(structure["models_dir"], out / "models")

    # Copy macros from parent
    if structure["macros_dir"] and structure["macros_dir"].exists():
        copytree_ignore_pycache(structure["macros_dir"], out / "macros")

    # Copy seeds from integration_tests
    if structure["seed_dir"] and structure["seed_dir"].exists():
        seed_dest = out / "seeds"
        copytree_ignore_pycache(structure["seed_dir"], seed_dest)

    # Also copy integration_tests macros if they exist
    int_macros = structure["int_tests_dir"] / "macros"
    if int_macros.exists():
        macros_dest = out / "macros"
        macros_dest.mkdir(exist_ok=True)
        copytree_ignore_pycache(int_macros, macros_dest)

    # Parse integration_tests dbt_project.yml for vars and column types
    flat_vars, seed_column_types, schema_var_value = parse_int_dbt_project(
        structure["int_dbt_project"]
    )

    # Generate dbt_project.yml
    # Merge parent config with integration test vars
    generate_dbt_project(
        out,
        project_name=pkg_name,
        profile_name=pkg_name,
        parent_dbt_project=structure["dbt_project"],
        int_dbt_project=structure["int_dbt_project"],
        flat_vars=flat_vars,
        seed_column_types=seed_column_types,
        schema_var_value=schema_var_value,
        int_project_name=int_name,
        structure_type="fivetran",
    )

    # Generate profiles.yml
    generate_profiles(out, pkg_name)

    return out


def assemble_playbook_project(name, structure, repo_entry, output_dir):
    """Assemble a self-contained project for a playbook-style repo."""
    out = output_dir / name
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)

    pkg_name = extract_project_name(structure["dbt_project"])

    # Copy models
    if structure["models_dir"] and structure["models_dir"].exists():
        copytree_ignore_pycache(structure["models_dir"], out / "models")

    # Copy macros
    if structure["macros_dir"] and structure["macros_dir"].exists():
        copytree_ignore_pycache(structure["macros_dir"], out / "macros")

    # Copy seeds (may be in data/ or seeds/)
    if structure["seed_dir"] and structure["seed_dir"].exists():
        seed_dest = out / "seeds"
        copytree_ignore_pycache(structure["seed_dir"], seed_dest)

    # Copy dbt_project.yml and adapt
    generate_dbt_project(
        out,
        project_name=pkg_name,
        profile_name=pkg_name,
        parent_dbt_project=structure["dbt_project"],
        int_dbt_project=None,
        flat_vars={},
        seed_column_types={},
        schema_var_value=None,
        int_project_name=None,
        structure_type="playbook",
    )

    generate_profiles(out, pkg_name)
    return out


def assemble_subproject(name, structure, repo_entry, output_dir):
    """Assemble a self-contained subproject (e.g., dbt_artifacts/integration_test_project)."""
    out = output_dir / name
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)

    int_dir = structure["int_tests_dir"]
    pkg_name = extract_project_name(structure["dbt_project"])

    # Copy entire integration test project
    for item in int_dir.iterdir():
        if item.name in (".git", "__pycache__", "target", "dbt_packages", "logs"):
            continue
        dest = out / item.name
        if item.is_dir():
            copytree_ignore_pycache(item, dest)
        else:
            shutil.copy2(item, dest)

    # Also copy parent macros if they exist
    parent_macros = int_dir.parent / "macros"
    if parent_macros.exists():
        macros_dest = out / "macros"
        macros_dest.mkdir(exist_ok=True)
        copytree_ignore_pycache(parent_macros, macros_dest)

    # Also copy parent models if they exist and aren't in the subproject
    parent_models = int_dir.parent / "models"
    models_dest = out / "models"
    if parent_models.exists() and not models_dest.exists():
        copytree_ignore_pycache(parent_models, models_dest)

    generate_profiles(out, pkg_name)
    return out


def _sanitize_config(obj, depth=0, force_enable=False):
    """Recursively sanitize a config dict, removing Jinja artifacts and invalid values.

    If force_enable is True, any +enabled keys that resolved to False are forced to True
    (since we want seeds/models to actually run in our test projects).
    """
    if isinstance(obj, dict):
        result = {}
        for k, v in obj.items():
            if isinstance(k, str) and ("__jinja__" in k or "{{" in k):
                continue
            sanitized = _sanitize_config(v, depth + 1, force_enable=force_enable)
            # Force +enabled to true for test projects
            if force_enable and k == "+enabled" and (sanitized is False or sanitized == "False" or sanitized == "false"):
                sanitized = True
            if sanitized is not None:
                result[k] = sanitized
        return result if result else None
    elif isinstance(obj, list):
        items = [_sanitize_config(item, depth + 1, force_enable=force_enable) for item in obj]
        filtered = [i for i in items if i is not None]
        # Preserve empty lists (used as var defaults like stripe_sources: [])
        return filtered if filtered else []
    elif isinstance(obj, str):
        if "__jinja__" in obj or "{{" in obj or "{%" in obj:
            # Try to resolve simple Jinja booleans
            if "true" in obj.lower() and "false" not in obj.lower():
                return True
            if "false" in obj.lower() and "true" not in obj.lower():
                return False
            return None
        return obj
    else:
        return obj


def _dump_yaml_section(data, indent=0):
    """Dump a nested dict as YAML lines."""
    import yaml
    lines = []
    prefix = "  " * indent

    def _quote_key(key):
        """Quote a YAML key if it contains special characters."""
        s = str(key)
        if any(c in s for c in ":{}[],'\"#&*!|>%@`"):
            return f'"{s}"'
        return s

    if isinstance(data, dict):
        for k, v in data.items():
            qk = _quote_key(k)
            if isinstance(v, dict):
                lines.append(f"{prefix}{qk}:")
                lines.extend(_dump_yaml_section(v, indent + 1))
            elif isinstance(v, list):
                if not v:
                    lines.append(f"{prefix}{qk}: []")
                else:
                    dumped = yaml.dump(v, default_flow_style=True).strip()
                    lines.append(f"{prefix}{qk}: {dumped}")
            elif isinstance(v, bool):
                lines.append(f"{prefix}{qk}: {str(v).lower()}")
            elif isinstance(v, str):
                if " " in v or ":" in v or v.startswith("{"):
                    lines.append(f'{prefix}{qk}: "{v}"')
                else:
                    lines.append(f"{prefix}{qk}: {v}")
            elif v is not None:
                lines.append(f"{prefix}{qk}: {v}")
    return lines


def generate_dbt_project(
    out_dir,
    project_name,
    profile_name,
    parent_dbt_project,
    int_dbt_project,
    flat_vars,
    seed_column_types,
    schema_var_value,
    int_project_name,
    structure_type,
):
    """Generate a merged dbt_project.yml."""
    # Parse parent dbt_project.yml for configs we want to copy.
    # Pass flat_vars (from integration test) so source() can resolve identifiers.
    parent_data = None
    if parent_dbt_project and parent_dbt_project.exists():
        try:
            parent_data = parse_yaml_with_jinja(
                parent_dbt_project.read_text(), extra_vars=flat_vars
            )
        except Exception:
            pass

    lines = []
    lines.append(f"name: '{project_name}'")
    lines.append("config-version: 2")
    lines.append(f"profile: '{profile_name}'")
    lines.append("")

    if structure_type == "fivetran":
        lines.append('model-paths: ["models"]')
        lines.append('seed-paths: ["seeds"]')
        lines.append('macro-paths: ["macros"]')
    elif structure_type == "playbook":
        lines.append('model-paths: ["models"]')
        lines.append('seed-paths: ["seeds"]')
        if (out_dir / "macros").exists():
            lines.append('macro-paths: ["macros"]')

    # Vars section
    # For playbook projects, copy vars from parent dbt_project.yml
    parent_vars = {}
    if parent_data and isinstance(parent_data, dict):
        parent_vars = parent_data.get("vars", {}) or {}
        if isinstance(parent_vars, dict):
            parent_vars = _sanitize_config(parent_vars) or {}

    # Merge parent vars with integration test vars
    merged_vars = dict(parent_vars)
    if schema_var_value:
        # Find the schema var name
        schema_var_name = None
        if parent_dbt_project and parent_dbt_project.exists():
            content = parent_dbt_project.read_text()
            matches = re.findall(r"var\(['\"](\w+_schema)['\"]", content)
            if matches:
                schema_var_name = matches[0]
        if not schema_var_name:
            models_dir = out_dir / "models"
            if models_dir.exists():
                for yml_path in models_dir.rglob("*.yml"):
                    try:
                        yml_content = yml_path.read_text()
                        matches = re.findall(r"var\(['\"](\w+_schema)['\"]", yml_content)
                        if matches:
                            schema_var_name = matches[0]
                            break
                    except Exception:
                        continue
        if schema_var_name:
            merged_vars[schema_var_name] = schema_var_value

    if flat_vars:
        # Nest under project name
        pkg_vars = merged_vars.get(project_name, {})
        if not isinstance(pkg_vars, dict):
            pkg_vars = {}
        pkg_vars.update(flat_vars)
        merged_vars[project_name] = pkg_vars

    if merged_vars:
        lines.append("")
        lines.append("vars:")
        lines.extend(_dump_yaml_section(merged_vars, indent=1))

    # Seeds section
    # Start from parent seeds config (for +schema, +quote_columns, etc.)
    parent_seeds = {}
    if parent_data and isinstance(parent_data, dict):
        parent_seeds = parent_data.get("seeds", {}) or {}
        if isinstance(parent_seeds, dict):
            parent_seeds = _sanitize_config(parent_seeds, force_enable=True) or {}

    # Merge with column types from integration tests
    if seed_column_types or parent_seeds:
        lines.append("")
        lines.append("seeds:")

        if parent_seeds:
            lines.extend(_dump_yaml_section(parent_seeds, indent=1))
        elif seed_column_types:
            # No parent seed config, just write column types
            lines.append(f"  {project_name}:")
            lines.append("    +quote_columns: false")

        # Add column types under the project name (if we have them and they're not
        # already represented in parent_seeds)
        if seed_column_types and not parent_seeds:
            for seed_name, col_types in sorted(seed_column_types.items()):
                if col_types:
                    lines.append(f"    {seed_name}:")
                    lines.append("      +column_types:")
                    for col, typ in sorted(col_types.items()):
                        lines.append(f"        {col}: {typ}")

    # Models section - copy from parent dbt_project.yml
    if parent_data and isinstance(parent_data, dict) and "models" in parent_data:
        models_config = _sanitize_config(parent_data["models"])
        if models_config and isinstance(models_config, dict):
            lines.append("")
            lines.append("models:")
            lines.extend(_dump_yaml_section(models_config, indent=1))

    content = "\n".join(lines) + "\n"
    (out_dir / "dbt_project.yml").write_text(content)


def generate_profiles(out_dir, profile_name):
    """Generate profiles.yml with DuckDB and DataFusion targets."""
    content = f"""{profile_name}:
  target: duckdb
  outputs:
    duckdb:
      type: duckdb
      path: target/{profile_name}.duckdb
      schema: main
      threads: 1
    datafusion:
      type: datafusion
      path: target/{profile_name}.db
      schema: main
      threads: 1
"""
    (out_dir / "profiles.yml").write_text(content)


def count_files(directory, pattern="*.csv"):
    """Count files matching pattern in directory."""
    if not directory or not directory.exists():
        return 0
    return len(list(directory.rglob(pattern)))


def assemble_project(repo_entry, dry_run=False):
    """Assemble a self-contained project for a single repo."""
    name = repo_entry["name"]
    print(f"\n{'[DRY RUN] ' if dry_run else ''}Processing: {name}")

    try:
        repo_path = clone_repo(repo_entry)
    except Exception as e:
        print(f"  ERROR cloning: {e}")
        return None

    structure = detect_structure(repo_path)
    print(f"  Type: {structure['type']}")
    print(f"  Seeds: {structure['seed_dir']}")

    seed_count = count_files(structure["seed_dir"])
    model_count = count_files(structure["models_dir"], "*.sql") if structure["models_dir"] else 0
    print(f"  Seed CSVs: {seed_count}, Model SQLs: {model_count}")

    if dry_run:
        return None

    try:
        if structure["type"] == "fivetran":
            return assemble_fivetran_project(name, structure, repo_entry, OUTPUT_DIR)
        elif structure["type"] == "playbook":
            return assemble_playbook_project(name, structure, repo_entry, OUTPUT_DIR)
        elif structure["type"] == "subproject":
            return assemble_subproject(name, structure, repo_entry, OUTPUT_DIR)
        else:
            print(f"  SKIP: unknown type {structure['type']}")
            return None
    except Exception as e:
        print(f"  ERROR assembling: {e}")
        import traceback
        traceback.print_exc()
        return None


HUB_TO_GITHUB = {
    "fivetran/fivetran_utils": "fivetran/dbt_fivetran_utils",
    "dbt-labs/dbt_utils": "dbt-labs/dbt-utils",
    "dbt-labs/spark_utils": "dbt-labs/spark-utils",
    "calogica/dbt_expectations": "calogica/dbt-expectations",
    "calogica/dbt_date": "calogica/dbt-date",
    "dbt-labs/dbt_external_tables": "dbt-labs/dbt-external-tables",
    "dbt-labs/codegen": "dbt-labs/dbt-codegen",
    "dbt-labs/audit_helper": "dbt-labs/dbt-audit-helper",
    "dbt-labs/metrics": "dbt-labs/dbt_metrics",
    "elementary-data/elementary": "elementary-data/elementary",
    "snowplow/snowplow_utils": "snowplow/dbt-snowplow-utils",
    "snowplow/snowplow_web": "snowplow/dbt-snowplow-web",
    "snowplow/snowplow_mobile": "snowplow/dbt-snowplow-mobile",
    "snowplow/snowplow_ecommerce": "snowplow/dbt-snowplow-ecommerce",
}


def install_packages_for_project(project_dir, repo_entry):
    """Install dbt package dependencies for an assembled project.

    Parses packages.yml from the cached source repo, resolves dependencies,
    clones them, and copies macros into dbt_packages/.
    """
    name = repo_entry["name"]
    org_repo = repo_entry["repo"]
    repo_name = org_repo.split("/")[-1]
    cached_repo = CACHE_DIR / repo_name

    # Find packages.yml in the cached repo
    packages_yml = None
    for candidate in [
        cached_repo / "packages.yml",
        cached_repo / "integration_tests" / "packages.yml",
    ]:
        if candidate.exists():
            packages_yml = candidate
            break

    if not packages_yml:
        return

    try:
        import yaml
        content = packages_yml.read_text()
        data = yaml.safe_load(content)
    except Exception:
        return

    if not data or "packages" not in data:
        return

    dbt_packages_dir = project_dir / "dbt_packages"
    dbt_packages_dir.mkdir(exist_ok=True)

    # Also check the parent repo's packages.yml for transitive deps
    parent_packages_ymls = [packages_yml]
    if (cached_repo / "packages.yml").exists() and packages_yml != cached_repo / "packages.yml":
        parent_packages_ymls.append(cached_repo / "packages.yml")

    all_hub_packages = set()
    for yml_path in parent_packages_ymls:
        try:
            yml_data = yaml.safe_load(yml_path.read_text())
            if yml_data and "packages" in yml_data:
                for pkg in yml_data["packages"]:
                    if "package" in pkg:
                        all_hub_packages.add(pkg["package"])
        except Exception:
            continue

    # Always include dbt_utils — nearly every package depends on it transitively
    all_hub_packages.add("dbt-labs/dbt_utils")

    # Install each hub package
    for hub_name in all_hub_packages:
        github_repo = HUB_TO_GITHUB.get(hub_name)
        if not github_repo:
            # Try to guess: fivetran/foo -> fivetran/dbt_foo
            org, pkg = hub_name.split("/", 1)
            github_repo = f"{org}/dbt_{pkg}"

        pkg_short = hub_name.split("/")[-1]
        pkg_dest = dbt_packages_dir / pkg_short

        if pkg_dest.exists():
            continue

        # Clone or reuse cached repo
        pkg_cache = CACHE_DIR / f"_pkg_{github_repo.replace('/', '_')}"
        if not pkg_cache.exists():
            url = f"https://github.com/{github_repo}.git"
            try:
                subprocess.run(
                    ["git", "clone", "--depth", "1", url, str(pkg_cache)],
                    check=True, capture_output=True, text=True,
                )
                print(f"    Cloned package: {hub_name}")
            except subprocess.CalledProcessError as e:
                print(f"    WARN: could not clone package {hub_name} ({github_repo}): {e.stderr.strip()}")
                continue

        # Copy macros from the package
        pkg_macros = pkg_cache / "macros"
        if pkg_macros.exists():
            pkg_dest.mkdir(parents=True, exist_ok=True)
            macros_dest = pkg_dest / "macros"
            if not macros_dest.exists():
                copytree_ignore_pycache(pkg_macros, macros_dest)

            # Copy dbt_project.yml so the package name is known
            pkg_dbt_project = pkg_cache / "dbt_project.yml"
            if pkg_dbt_project.exists():
                shutil.copy2(pkg_dbt_project, pkg_dest / "dbt_project.yml")

            # Copy packages.yml so transitive deps can be resolved
            pkg_packages_yml = pkg_cache / "packages.yml"
            if pkg_packages_yml.exists():
                shutil.copy2(pkg_packages_yml, pkg_dest / "packages.yml")

            print(f"    Installed: {hub_name} -> dbt_packages/{pkg_short}/")
        else:
            print(f"    WARN: no macros/ in {github_repo}")

    # Recursively install deps of installed packages (iterate until stable)
    changed = True
    while changed:
        changed = False
        for pkg_dir in list(dbt_packages_dir.iterdir()):
            if not pkg_dir.is_dir():
                continue
            sub_packages_yml = pkg_dir / "packages.yml"
            if not sub_packages_yml.exists():
                continue
            try:
                import yaml
                sub_data = yaml.safe_load(sub_packages_yml.read_text())
                if sub_data and "packages" in sub_data:
                    for pkg in sub_data["packages"]:
                        if "package" in pkg:
                            hub_name = pkg["package"]
                            pkg_short = hub_name.split("/")[-1]
                            if (dbt_packages_dir / pkg_short).exists():
                                continue
                            # Clone and install this transitive dep
                            github_repo = HUB_TO_GITHUB.get(hub_name)
                            if not github_repo:
                                org, pkn = hub_name.split("/", 1)
                                github_repo = f"{org}/dbt_{pkn}"
                            pkg_cache = CACHE_DIR / f"_pkg_{github_repo.replace('/', '_')}"
                            if not pkg_cache.exists():
                                url = f"https://github.com/{github_repo}.git"
                                try:
                                    subprocess.run(
                                        ["git", "clone", "--depth", "1", url, str(pkg_cache)],
                                        check=True, capture_output=True, text=True,
                                    )
                                except subprocess.CalledProcessError:
                                    continue
                            pkg_macros = pkg_cache / "macros"
                            if pkg_macros.exists():
                                pkg_dest = dbt_packages_dir / pkg_short
                                pkg_dest.mkdir(parents=True, exist_ok=True)
                                macros_dest = pkg_dest / "macros"
                                if not macros_dest.exists():
                                    copytree_ignore_pycache(pkg_macros, macros_dest)
                                pkg_dbt_project = pkg_cache / "dbt_project.yml"
                                if pkg_dbt_project.exists():
                                    shutil.copy2(pkg_dbt_project, pkg_dest / "dbt_project.yml")
                                pkg_packages_yml_src = pkg_cache / "packages.yml"
                                if pkg_packages_yml_src.exists():
                                    shutil.copy2(pkg_packages_yml_src, pkg_dest / "packages.yml")
                                print(f"    Installed (transitive): {hub_name}")
                                changed = True
            except Exception:
                continue


def main():
    parser = argparse.ArgumentParser(description="Generate compat test projects")
    parser.add_argument("--repos", help="Comma-separated list of repo names to process")
    parser.add_argument("--dry-run", action="store_true", help="Just show what would be done")
    parser.add_argument("--clean", action="store_true", help="Remove output dir before generating")
    parser.add_argument("--install-packages", action="store_true", help="Install dbt package dependencies")
    args = parser.parse_args()

    filter_names = args.repos.split(",") if args.repos else None
    repos = load_repos(filter_names)

    print(f"Processing {len(repos)} repos")
    print(f"Cache dir: {CACHE_DIR}")
    print(f"Output dir: {OUTPUT_DIR}")

    if args.clean and OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    results = {"success": [], "error": [], "skip": []}

    for repo_entry in repos:
        result = assemble_project(repo_entry, dry_run=args.dry_run)
        if result:
            results["success"].append(repo_entry["name"])
            if args.install_packages:
                install_packages_for_project(result, repo_entry)
        elif not args.dry_run:
            results["error"].append(repo_entry["name"])

    if not args.dry_run:
        print(f"\n{'='*60}")
        print(f"Generated: {len(results['success'])} projects")
        print(f"Errors: {len(results['error'])}")
        if results["error"]:
            for name in results["error"]:
                print(f"  - {name}")

        # Count total seeds and models
        total_seeds = 0
        total_models = 0
        for name in results["success"]:
            project_dir = OUTPUT_DIR / name
            total_seeds += count_files(project_dir / "seeds")
            total_models += count_files(project_dir / "models", "*.sql")
        print(f"Total seed CSVs: {total_seeds}")
        print(f"Total model SQLs: {total_models}")


if __name__ == "__main__":
    main()
