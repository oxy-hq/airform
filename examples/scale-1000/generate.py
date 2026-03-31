#!/usr/bin/env python3
"""Generate a dbt project with exactly 1000 SQL models."""

import os
import random

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
random.seed(42)

# ── Seed definitions ──────────────────────────────────────────────────────────
SEEDS = {
    "users": ["id", "account_id", "email", "first_name", "last_name", "created_at", "updated_at", "status", "country", "signup_source"],
    "accounts": ["id", "account_name", "industry", "company_size", "plan_type", "created_at", "status", "region", "owner_id", "mrr"],
    "subscriptions": ["id", "account_id", "plan_id", "start_date", "end_date", "status", "amount", "currency", "interval_months", "auto_renew"],
    "invoices": ["id", "account_id", "invoice_date", "due_date", "amount", "tax", "total", "status", "currency", "paid_at"],
    "payments": ["id", "invoice_id", "amount", "method", "status", "processed_at", "currency", "fee", "net_amount", "reference_id"],
    "events": ["id", "user_id", "event_type", "event_name", "created_at", "properties", "session_id", "platform", "country", "device_type"],
    "sessions": ["id", "user_id", "started_at", "ended_at", "duration_seconds", "page_count", "platform", "browser", "country", "is_bounce"],
    "page_views": ["id", "session_id", "user_id", "page_url", "page_title", "viewed_at", "time_on_page", "referrer", "device_type", "is_exit"],
    "support_tickets": ["id", "user_id", "account_id", "subject", "priority", "status", "created_at", "resolved_at", "category", "agent_id"],
    "feature_usage": ["id", "user_id", "feature_name", "usage_count", "first_used_at", "last_used_at", "is_active", "platform", "version", "category"],
    "products": ["id", "product_name", "category", "price", "cost", "sku", "status", "created_at", "weight", "supplier_id"],
    "orders": ["id", "account_id", "user_id", "order_date", "total_amount", "status", "shipping_method", "discount", "tax", "currency"],
    "order_items": ["id", "order_id", "product_id", "quantity", "unit_price", "discount", "total_price", "sku", "status", "shipped_at"],
    "campaigns": ["id", "campaign_name", "channel", "start_date", "end_date", "budget", "spend", "status", "target_audience", "goal"],
    "channels": ["id", "channel_name", "channel_type", "is_active", "created_at", "cost_per_click", "cost_per_impression", "region", "category", "priority"],
    "employees": ["id", "department_id", "first_name", "last_name", "email", "hire_date", "title", "salary", "status", "manager_id"],
    "departments": ["id", "department_name", "cost_center", "head_count", "budget", "location", "created_at", "status", "parent_id", "region"],
    "warehouses": ["id", "warehouse_name", "location", "capacity", "utilization", "status", "manager_id", "region", "created_at", "type"],
    "shipments": ["id", "order_id", "warehouse_id", "shipped_at", "delivered_at", "carrier", "tracking_number", "status", "weight", "cost"],
    "compliance_records": ["id", "account_id", "record_type", "status", "reviewed_at", "reviewer_id", "notes", "risk_level", "category", "created_at"],
}

SEED_NAMES = list(SEEDS.keys())

DOMAINS = ["core", "finance", "marketing", "product", "operations", "hr", "sales", "logistics", "analytics", "compliance"]

# Sample data generators
def sample_rows(cols, n):
    """Generate n rows of sample CSV data."""
    rows = []
    for i in range(1, n + 1):
        row = []
        for c in cols:
            if c == "id":
                row.append(str(i))
            elif c.endswith("_id") or c == "manager_id" or c == "owner_id" or c == "reviewer_id" or c == "agent_id" or c == "supplier_id":
                row.append(str(random.randint(1, 10)))
            elif c in ("email",):
                row.append(f"user{i}@example.com")
            elif c in ("first_name",):
                row.append(random.choice(["Alice", "Bob", "Carol", "Dan", "Eve", "Frank", "Grace", "Hank", "Ivy", "Jack"]))
            elif c in ("last_name",):
                row.append(random.choice(["Smith", "Jones", "Lee", "Kim", "Chen", "Brown", "Davis", "Wilson", "Moore", "Taylor"]))
            elif c in ("status",):
                row.append(random.choice(["active", "inactive", "pending"]))
            elif c in ("country", "region", "location"):
                row.append(random.choice(["US", "UK", "DE", "FR", "JP", "CA", "AU", "BR", "IN", "KR"]))
            elif c in ("currency",):
                row.append(random.choice(["USD", "EUR", "GBP"]))
            elif c in ("amount", "total", "tax", "fee", "net_amount", "price", "cost", "budget", "spend", "salary", "mrr", "unit_price", "total_price", "total_amount", "discount", "weight", "cost_per_click", "cost_per_impression"):
                row.append(str(round(random.uniform(10, 10000), 2)))
            elif c in ("quantity", "head_count", "page_count", "usage_count", "capacity", "utilization", "duration_seconds", "time_on_page", "interval_months"):
                row.append(str(random.randint(1, 100)))
            elif c in ("is_bounce", "is_exit", "is_active", "auto_renew"):
                row.append(random.choice(["true", "false"]))
            elif "date" in c or "at" in c:
                row.append(f"2024-{random.randint(1,12):02d}-{random.randint(1,28):02d}")
            elif c in ("plan_type", "method", "shipping_method", "carrier"):
                row.append(random.choice(["standard", "premium", "express"]))
            elif c in ("priority", "risk_level"):
                row.append(random.choice(["low", "medium", "high"]))
            elif c in ("category", "channel_type", "record_type", "type"):
                row.append(random.choice(["typeA", "typeB", "typeC"]))
            elif c in ("platform", "device_type", "browser"):
                row.append(random.choice(["web", "mobile", "desktop"]))
            else:
                row.append(f"{c}_{i}")
        rows.append(",".join(row))
    return rows


def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content)


# ── Generate dbt_project.yml ─────────────────────────────────────────────────
def gen_dbt_project():
    write_file(os.path.join(BASE_DIR, "dbt_project.yml"), """config-version: 2

name: "scale_1000"
version: "1.0.0"

profile: "scale_1000"

model-paths: ["models"]
seed-paths: ["seeds"]
test-paths: ["tests"]
analysis-paths: ["analyses"]
macro-paths: ["macros"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

seeds:
  scale_1000:
    +schema: raw

models:
  +start: "2024-01-01"
  scale_1000:
    staging:
      +materialized: view
    intermediate:
      +materialized: table
    marts:
      +materialized: table
""")


def gen_profiles():
    write_file(os.path.join(BASE_DIR, "profiles.yml"), """scale_1000:
  target: duckdb
  outputs:
    datafusion:
      type: datafusion
      path: target/scale_1000.db
      schema: main
      threads: 1
    duckdb:
      type: duckdb
      path: target/scale_1000.duckdb
      schema: main
      threads: 1
""")


def gen_config():
    write_file(os.path.join(BASE_DIR, "config.yaml"), """gateways:
  duckdb:
    connection:
      type: duckdb
      database: target/scale_1000.duckdb

default_gateway: duckdb

model_defaults:
  dialect: duckdb
""")


# ── Seeds ─────────────────────────────────────────────────────────────────────
def gen_seeds():
    for name, cols in SEEDS.items():
        n_rows = random.randint(10, 15)
        header = ",".join(cols)
        rows = sample_rows(cols, n_rows)
        content = header + "\n" + "\n".join(rows) + "\n"
        write_file(os.path.join(BASE_DIR, "seeds", f"raw_{name}.csv"), content)


# ── Sources yml ───────────────────────────────────────────────────────────────
def gen_sources():
    tables = ""
    for name in SEED_NAMES:
        tables += f"      - name: raw_{name}\n        description: Raw {name} data.\n"
    write_file(os.path.join(BASE_DIR, "models", "staging", "_sources.yml"), f"""version: 2

sources:
  - name: raw
    schema: raw
    description: Raw seed data.
    tables:
{tables}""")


# ── Staging models (200) ─────────────────────────────────────────────────────
STG_MODELS = []

def gen_staging():
    # 10 staging models per seed = 200
    for seed_name in SEED_NAMES:
        cols = SEEDS[seed_name]
        for variant in range(1, 11):
            model_name = f"stg_{seed_name}_{variant:02d}"
            STG_MODELS.append(model_name)
            # Pick a subset of columns, always include 'id'
            selected = ["id"] + random.sample([c for c in cols if c != "id"], k=min(random.randint(3, 7), len(cols) - 1))
            # Rename id to a descriptive key
            renames = []
            id_alias = f"{seed_name.rstrip('s')}_id" if not seed_name.endswith("ss") else f"{seed_name}_id"
            for c in selected:
                if c == "id":
                    renames.append(f"        id as {id_alias}")
                else:
                    renames.append(f"        {c}")

            sql = f"""with source as (
    select * from {{{{ source('raw', 'raw_{seed_name}') }}}}
),

renamed as (
    select
{chr(44).join(r + chr(10) for r in renames).rstrip(chr(10))}
    from source
)

select * from renamed
"""
            write_file(os.path.join(BASE_DIR, "models", "staging", f"{model_name}.sql"), sql)


# ── Intermediate models (200), ~20 ephemeral ─────────────────────────────────
INT_MODELS = []
EPHEMERAL_MODELS = set()

# SQL patterns for intermediate models
def _int_join(name, ref1, ref2, cols1, cols2):
    """Simple join pattern."""
    return f"""with a as (
    select * from {{{{ ref('{ref1}') }}}}
),

b as (
    select * from {{{{ ref('{ref2}') }}}}
),

final as (
    select
        a.{cols1[0]},
{chr(10).join(f"        a.{c}," for c in cols1[1:3])}
{chr(10).join(f"        b.{c}" + ("," if i < min(len(cols2), 3) - 1 else "") for i, c in enumerate(cols2[:3]))}
    from a
    left join b on a.{cols1[0]} = b.{cols2[0]}
)

select * from final
"""


def _int_agg(name, ref1, group_col, agg_col):
    """Aggregation pattern."""
    return f"""with source as (
    select * from {{{{ ref('{ref1}') }}}}
),

final as (
    select
        {group_col},
        count(*) as record_count,
        sum(cast({agg_col} as int)) as total_{agg_col}
    from source
    group by {group_col}
)

select * from final
"""


def _int_window(name, ref1, partition_col, order_col):
    """Window function pattern."""
    return f"""with source as (
    select * from {{{{ ref('{ref1}') }}}}
),

final as (
    select
        *,
        row_number() over (partition by {partition_col} order by {order_col}) as row_num
    from source
)

select * from final
"""


def _int_case(name, ref1, col):
    """CASE + COALESCE pattern."""
    return f"""with source as (
    select * from {{{{ ref('{ref1}') }}}}
),

final as (
    select
        *,
        case
            when {col} = 'active' then 1
            when {col} = 'inactive' then 0
            else -1
        end as {col}_flag,
        coalesce({col}, 'unknown') as {col}_clean
    from source
)

select * from final
"""


def gen_intermediate():
    # Generate 200 intermediate models
    patterns = [_int_join, _int_agg, _int_window, _int_case]
    ephemeral_indices = set(random.sample(range(200), 20))

    for i in range(200):
        model_name = f"int_model_{i + 1:03d}"
        INT_MODELS.append(model_name)
        if i in ephemeral_indices:
            EPHEMERAL_MODELS.add(model_name)

        pattern_idx = i % 4
        # Pick staging models to reference
        ref1 = STG_MODELS[i % len(STG_MODELS)]
        ref2 = STG_MODELS[(i + 7) % len(STG_MODELS)]

        seed1 = SEED_NAMES[i % len(SEED_NAMES)]
        cols1 = SEEDS[seed1]
        seed2 = SEED_NAMES[(i + 7) % len(SEED_NAMES)]
        cols2 = SEEDS[seed2]

        # Compute a safe id alias for cols references
        id1 = f"{seed1.rstrip('s')}_id" if not seed1.endswith("ss") else f"{seed1}_id"
        id2 = f"{seed2.rstrip('s')}_id" if not seed2.endswith("ss") else f"{seed2}_id"
        safe_cols1 = [id1] + [c for c in cols1 if c != "id"]
        safe_cols2 = [id2] + [c for c in cols2 if c != "id"]

        if pattern_idx == 0:
            sql = _int_join(model_name, ref1, ref2, safe_cols1, safe_cols2)
        elif pattern_idx == 1:
            # pick a groupable and a numeric-ish column
            group_col = safe_cols1[1] if len(safe_cols1) > 1 else safe_cols1[0]
            agg_col = safe_cols1[0]  # id-like, castable to int
            sql = _int_agg(model_name, ref1, group_col, agg_col)
        elif pattern_idx == 2:
            partition_col = safe_cols1[1] if len(safe_cols1) > 1 else safe_cols1[0]
            order_col = safe_cols1[0]
            sql = _int_window(model_name, ref1, partition_col, order_col)
        else:
            # Find a status-like column
            status_cols = [c for c in safe_cols1 if c == "status"]
            col = status_cols[0] if status_cols else safe_cols1[1]
            sql = _int_case(model_name, ref1, col)

        write_file(os.path.join(BASE_DIR, "models", "intermediate", f"{model_name}.sql"), sql)


# ── Mart models (600 = 60 per domain) ────────────────────────────────────────
MART_MODELS = {d: [] for d in DOMAINS}

# Mart SQL patterns
def _mart_simple_ref(ref_name, cols):
    """Simple select from a ref."""
    col_list = ", ".join(cols[:5])
    return f"""select
    {col_list}
from {{{{ ref('{ref_name}') }}}}
"""


def _mart_join_two(ref1, ref2, join_col):
    """Join two refs."""
    return f"""with a as (
    select * from {{{{ ref('{ref1}') }}}}
),

b as (
    select * from {{{{ ref('{ref2}') }}}}
)

select
    a.*,
    b.*
from a
inner join b on a.{join_col} = b.{join_col}
"""


def _mart_agg(ref_name, group_col):
    """Aggregation mart."""
    return f"""select
    {group_col},
    count(*) as total_records,
    sum(1) as sum_val
from {{{{ ref('{ref_name}') }}}}
group by {group_col}
"""


def _mart_cte_window(ref_name, partition_col, order_col):
    """CTE with window function."""
    return f"""with base as (
    select * from {{{{ ref('{ref_name}') }}}}
),

ranked as (
    select
        *,
        row_number() over (partition by {partition_col} order by {order_col}) as rn
    from base
)

select * from ranked where rn = 1
"""


def _mart_case_coalesce(ref_name, col):
    """CASE + COALESCE mart."""
    return f"""select
    *,
    case
        when {col} = 'active' then 'enabled'
        when {col} = 'inactive' then 'disabled'
        else 'other'
    end as {col}_label,
    coalesce({col}, 'none') as {col}_filled
from {{{{ ref('{ref_name}') }}}}
"""


def _mart_multi_ref(ref1, ref2, ref3, join_col):
    """Three-way join."""
    return f"""with t1 as (
    select * from {{{{ ref('{ref1}') }}}}
),

t2 as (
    select * from {{{{ ref('{ref2}') }}}}
),

t3 as (
    select * from {{{{ ref('{ref3}') }}}}
)

select
    t1.*
from t1
left join t2 on cast(t1.{join_col} as varchar) = cast(t2.{join_col} as varchar)
left join t3 on cast(t1.{join_col} as varchar) = cast(t3.{join_col} as varchar)
"""


def gen_marts():
    mart_patterns = [_mart_simple_ref, _mart_join_two, _mart_agg, _mart_cte_window, _mart_case_coalesce, _mart_multi_ref]

    for domain_idx, domain in enumerate(DOMAINS):
        for j in range(60):
            model_name = f"{domain}_model_{j + 1:03d}"
            MART_MODELS[domain].append(model_name)
            global_idx = domain_idx * 60 + j
            pattern_idx = global_idx % 6

            # Pick references - mix of staging and intermediate (non-ephemeral for safety)
            non_eph_int = [m for m in INT_MODELS if m not in EPHEMERAL_MODELS]
            stg_ref = STG_MODELS[global_idx % len(STG_MODELS)]
            int_ref = non_eph_int[global_idx % len(non_eph_int)]
            int_ref2 = non_eph_int[(global_idx + 13) % len(non_eph_int)]

            # Get columns for the staging ref
            seed_idx = global_idx % len(SEED_NAMES)
            seed_name = SEED_NAMES[seed_idx]
            cols = SEEDS[seed_name]
            id_alias = f"{seed_name.rstrip('s')}_id" if not seed_name.endswith("ss") else f"{seed_name}_id"
            safe_cols = [id_alias] + [c for c in cols if c != "id"]

            if pattern_idx == 0:
                sql = _mart_simple_ref(stg_ref, safe_cols)
            elif pattern_idx == 1:
                # join stg + int on a common-ish column - use first col
                sql = _mart_join_two(stg_ref, int_ref, safe_cols[0])
            elif pattern_idx == 2:
                group_col = safe_cols[1] if len(safe_cols) > 1 else safe_cols[0]
                sql = _mart_agg(stg_ref, group_col)
            elif pattern_idx == 3:
                partition_col = safe_cols[1] if len(safe_cols) > 1 else safe_cols[0]
                order_col = safe_cols[0]
                sql = _mart_cte_window(stg_ref, partition_col, order_col)
            elif pattern_idx == 4:
                status_cols = [c for c in safe_cols if c == "status"]
                col = status_cols[0] if status_cols else safe_cols[1]
                sql = _mart_case_coalesce(stg_ref, col)
            else:
                sql = _mart_multi_ref(stg_ref, int_ref, int_ref2, safe_cols[0])

            write_file(os.path.join(BASE_DIR, "models", "marts", domain, f"{model_name}.sql"), sql)


# ── Schema files ──────────────────────────────────────────────────────────────
def gen_staging_schema():
    lines = ["version: 2", "", "models:"]
    for m in STG_MODELS:
        seed_name = m.replace("stg_", "").rsplit("_", 1)[0]
        id_alias = f"{seed_name.rstrip('s')}_id" if not seed_name.endswith("ss") else f"{seed_name}_id"
        lines.append(f"  - name: {m}")
        lines.append(f"    description: Staged {seed_name} data.")
        lines.append(f"    columns:")
        lines.append(f"      - name: {id_alias}")
        lines.append(f"        description: Primary key.")
        lines.append(f"        tests:")
        lines.append(f"          - not_null")
    write_file(os.path.join(BASE_DIR, "models", "staging", "_schema.yml"), "\n".join(lines) + "\n")


def gen_intermediate_schema():
    lines = ["version: 2", "", "models:"]
    for m in INT_MODELS:
        lines.append(f"  - name: {m}")
        if m in EPHEMERAL_MODELS:
            lines.append(f"    description: Ephemeral intermediate model.")
            lines.append(f"    config:")
            lines.append(f"      materialized: ephemeral")
            # No tests for ephemeral
        else:
            lines.append(f"    description: Intermediate model.")
    write_file(os.path.join(BASE_DIR, "models", "intermediate", "_schema.yml"), "\n".join(lines) + "\n")


def gen_mart_schemas():
    for domain in DOMAINS:
        lines = ["version: 2", "", "models:"]
        for m in MART_MODELS[domain]:
            lines.append(f"  - name: {m}")
            lines.append(f"    description: Mart model in {domain} domain.")
        write_file(os.path.join(BASE_DIR, "models", "marts", domain, "_schema.yml"), "\n".join(lines) + "\n")


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    print("Generating scale-1000 dbt project...")
    gen_dbt_project()
    gen_profiles()
    gen_config()
    gen_seeds()
    gen_sources()
    gen_staging()
    gen_intermediate()
    gen_marts()
    gen_staging_schema()
    gen_intermediate_schema()
    gen_mart_schemas()

    total_sql = len(STG_MODELS) + len(INT_MODELS) + sum(len(v) for v in MART_MODELS.values())
    print(f"Generated {total_sql} SQL models.")
    print(f"  Staging: {len(STG_MODELS)}")
    print(f"  Intermediate: {len(INT_MODELS)} ({len(EPHEMERAL_MODELS)} ephemeral)")
    print(f"  Marts: {sum(len(v) for v in MART_MODELS.values())} across {len(DOMAINS)} domains")
    print(f"  Seeds: {len(SEEDS)}")
    # Create empty dirs for tests/analyses/macros
    os.makedirs(os.path.join(BASE_DIR, "tests"), exist_ok=True)
    os.makedirs(os.path.join(BASE_DIR, "analyses"), exist_ok=True)
    os.makedirs(os.path.join(BASE_DIR, "macros"), exist_ok=True)
    print("Done!")


if __name__ == "__main__":
    main()
