#!/usr/bin/env python3
"""Generate a dbt project with exactly 10000 SQL models."""

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

DOMAINS = [
    "core", "finance", "marketing", "product", "operations",
    "hr", "sales", "logistics", "analytics", "compliance",
    "customer_success", "engineering", "security", "data_quality", "executive",
    "billing", "partnerships", "onboarding", "retention", "growth",
]


def sample_rows(cols, n):
    rows = []
    for i in range(1, n + 1):
        row = []
        for c in cols:
            if c == "id":
                row.append(str(i))
            elif c.endswith("_id") or c in ("manager_id", "owner_id", "reviewer_id", "agent_id", "supplier_id"):
                row.append(str(random.randint(1, 10)))
            elif c == "email":
                row.append(f"user{i}@example.com")
            elif c == "first_name":
                row.append(random.choice(["Alice", "Bob", "Carol", "Dan", "Eve", "Frank", "Grace", "Hank", "Ivy", "Jack"]))
            elif c == "last_name":
                row.append(random.choice(["Smith", "Jones", "Lee", "Kim", "Chen", "Brown", "Davis", "Wilson", "Moore", "Taylor"]))
            elif c == "status":
                row.append(random.choice(["active", "inactive", "pending"]))
            elif c in ("country", "region", "location"):
                row.append(random.choice(["US", "UK", "DE", "FR", "JP"]))
            elif c == "currency":
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


def id_alias(seed_name):
    return f"{seed_name.rstrip('s')}_id" if not seed_name.endswith("ss") else f"{seed_name}_id"


def safe_cols(seed_name):
    cols = SEEDS[seed_name]
    return [id_alias(seed_name)] + [c for c in cols if c != "id"]


# ── Config files ─────────────────────────────────────────────────────────────

def gen_dbt_project():
    write_file(os.path.join(BASE_DIR, "dbt_project.yml"), """config-version: 2

name: "scale_10000"
version: "1.0.0"

profile: "scale_10000"

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
  scale_10000:
    +schema: raw

models:
  +start: "2024-01-01"
  scale_10000:
    staging:
      +materialized: view
    intermediate:
      +materialized: table
    marts:
      +materialized: table
""")


def gen_profiles():
    write_file(os.path.join(BASE_DIR, "profiles.yml"), """scale_10000:
  target: duckdb
  outputs:
    datafusion:
      type: datafusion
      path: target/scale_10000.db
      schema: main
      threads: 1
    duckdb:
      type: duckdb
      path: target/scale_10000.duckdb
      schema: main
      threads: 1
""")


def gen_config():
    write_file(os.path.join(BASE_DIR, "config.yaml"), """model_defaults:
  dialect: duckdb
""")


# ── Seeds ─────────────────────────────────────────────────────────────────────

def gen_seeds():
    for name, cols in SEEDS.items():
        n_rows = random.randint(10, 15)
        header = ",".join(cols)
        rows = sample_rows(cols, n_rows)
        write_file(os.path.join(BASE_DIR, "seeds", f"raw_{name}.csv"), header + "\n" + "\n".join(rows) + "\n")


# ── Sources ───────────────────────────────────────────────────────────────────

def gen_sources():
    tables = ""
    for name in SEED_NAMES:
        tables += f"      - name: raw_{name}\n"
    write_file(os.path.join(BASE_DIR, "models", "staging", "_sources.yml"),
               f"version: 2\n\nsources:\n  - name: raw\n    schema: raw\n    tables:\n{tables}")


# ── Staging (2000 models) ────────────────────────────────────────────────────

STG_MODELS = []

def gen_staging():
    # 100 variants per seed = 2000
    for seed_name in SEED_NAMES:
        cols = SEEDS[seed_name]
        for variant in range(1, 101):
            model_name = f"stg_{seed_name}_{variant:03d}"
            STG_MODELS.append(model_name)
            selected = ["id"] + random.sample([c for c in cols if c != "id"], k=min(random.randint(3, 7), len(cols) - 1))
            ia = id_alias(seed_name)
            renames = []
            for c in selected:
                if c == "id":
                    renames.append(f"        id as {ia}")
                else:
                    renames.append(f"        {c}")

            sql = f"""with source as (
    select * from {{{{ source('raw', 'raw_{seed_name}') }}}}
),
renamed as (
    select
{','.join(r + chr(10) for r in renames).rstrip(chr(10))}
    from source
)
select * from renamed
"""
            write_file(os.path.join(BASE_DIR, "models", "staging", f"{model_name}.sql"), sql)


# ── Intermediate (2000 models, ~200 ephemeral) ──────────────────────────────

INT_MODELS = []
EPHEMERAL_MODELS = set()

def gen_intermediate():
    ephemeral_indices = set(random.sample(range(2000), 200))

    for i in range(2000):
        model_name = f"int_model_{i + 1:04d}"
        INT_MODELS.append(model_name)
        if i in ephemeral_indices:
            EPHEMERAL_MODELS.add(model_name)

        ref1 = STG_MODELS[i % len(STG_MODELS)]
        ref2 = STG_MODELS[(i + 7) % len(STG_MODELS)]
        seed1 = SEED_NAMES[i % len(SEED_NAMES)]
        seed2 = SEED_NAMES[(i + 7) % len(SEED_NAMES)]
        sc1 = safe_cols(seed1)
        sc2 = safe_cols(seed2)
        pattern = i % 4

        if pattern == 0:
            sql = f"""with a as (select * from {{{{ ref('{ref1}') }}}}),
b as (select * from {{{{ ref('{ref2}') }}}})
select a.{sc1[0]}, a.{sc1[1] if len(sc1) > 1 else sc1[0]}, b.{sc2[1] if len(sc2) > 1 else sc2[0]}
from a left join b on a.{sc1[0]} = b.{sc2[0]}
"""
        elif pattern == 1:
            gc = sc1[1] if len(sc1) > 1 else sc1[0]
            sql = f"""select {gc}, count(*) as cnt, sum(cast({sc1[0]} as int)) as total
from {{{{ ref('{ref1}') }}}}
group by {gc}
"""
        elif pattern == 2:
            pc = sc1[1] if len(sc1) > 1 else sc1[0]
            sql = f"""select *, row_number() over (partition by {pc} order by {sc1[0]}) as rn
from {{{{ ref('{ref1}') }}}}
"""
        else:
            col = "status" if "status" in sc1 else sc1[1] if len(sc1) > 1 else sc1[0]
            sql = f"""select *,
    case when {col} = 'active' then 1 when {col} = 'inactive' then 0 else -1 end as {col}_flag,
    coalesce({col}, 'unknown') as {col}_clean
from {{{{ ref('{ref1}') }}}}
"""
        write_file(os.path.join(BASE_DIR, "models", "intermediate", f"{model_name}.sql"), sql)


# ── Marts (6000 = 300 per domain) ───────────────────────────────────────────

MART_MODELS = {d: [] for d in DOMAINS}

def gen_marts():
    non_eph = [m for m in INT_MODELS if m not in EPHEMERAL_MODELS]

    for domain_idx, domain in enumerate(DOMAINS):
        for j in range(300):
            model_name = f"{domain}_{j + 1:03d}"
            MART_MODELS[domain].append(model_name)
            gi = domain_idx * 300 + j
            pattern = gi % 6

            stg_ref = STG_MODELS[gi % len(STG_MODELS)]
            int_ref = non_eph[gi % len(non_eph)]
            int_ref2 = non_eph[(gi + 13) % len(non_eph)]

            seed_name = SEED_NAMES[gi % len(SEED_NAMES)]
            sc = safe_cols(seed_name)

            if pattern == 0:
                sql = f"select {', '.join(sc[:5])}\nfrom {{{{ ref('{stg_ref}') }}}}\n"
            elif pattern == 1:
                sql = f"""with a as (select * from {{{{ ref('{stg_ref}') }}}}),
b as (select * from {{{{ ref('{int_ref}') }}}})
select a.* from a inner join b on a.{sc[0]} = b.{sc[0]}
"""
            elif pattern == 2:
                gc = sc[1] if len(sc) > 1 else sc[0]
                sql = f"select {gc}, count(*) as total\nfrom {{{{ ref('{stg_ref}') }}}}\ngroup by {gc}\n"
            elif pattern == 3:
                pc = sc[1] if len(sc) > 1 else sc[0]
                sql = f"""with base as (select * from {{{{ ref('{stg_ref}') }}}}),
ranked as (select *, row_number() over (partition by {pc} order by {sc[0]}) as rn from base)
select * from ranked where rn = 1
"""
            elif pattern == 4:
                col = "status" if "status" in sc else sc[1] if len(sc) > 1 else sc[0]
                sql = f"""select *,
    case when {col} = 'active' then 'enabled' else 'other' end as {col}_label
from {{{{ ref('{stg_ref}') }}}}
"""
            else:
                sql = f"""with t1 as (select * from {{{{ ref('{stg_ref}') }}}}),
t2 as (select * from {{{{ ref('{int_ref}') }}}}),
t3 as (select * from {{{{ ref('{int_ref2}') }}}})
select t1.*
from t1
left join t2 on cast(t1.{sc[0]} as varchar) = cast(t2.{sc[0]} as varchar)
left join t3 on cast(t1.{sc[0]} as varchar) = cast(t3.{sc[0]} as varchar)
"""
            write_file(os.path.join(BASE_DIR, "models", "marts", domain, f"{model_name}.sql"), sql)


# ── Schema files ─────────────────────────────────────────────────────────────

def gen_staging_schema():
    lines = ["version: 2", "", "models:"]
    for m in STG_MODELS:
        seed_name = "_".join(m.replace("stg_", "").split("_")[:-1])
        ia = id_alias(seed_name)
        lines.append(f"  - name: {m}")
        lines.append(f"    columns:")
        lines.append(f"      - name: {ia}")
        lines.append(f"        tests: [not_null]")
    write_file(os.path.join(BASE_DIR, "models", "staging", "_schema.yml"), "\n".join(lines) + "\n")


def gen_intermediate_schema():
    lines = ["version: 2", "", "models:"]
    for m in INT_MODELS:
        lines.append(f"  - name: {m}")
        if m in EPHEMERAL_MODELS:
            lines.append(f"    config:")
            lines.append(f"      materialized: ephemeral")
    write_file(os.path.join(BASE_DIR, "models", "intermediate", "_schema.yml"), "\n".join(lines) + "\n")


def gen_mart_schemas():
    for domain in DOMAINS:
        lines = ["version: 2", "", "models:"]
        for m in MART_MODELS[domain]:
            lines.append(f"  - name: {m}")
        write_file(os.path.join(BASE_DIR, "models", "marts", domain, "_schema.yml"), "\n".join(lines) + "\n")


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    print("Generating scale-10000 dbt project...")
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

    total = len(STG_MODELS) + len(INT_MODELS) + sum(len(v) for v in MART_MODELS.values())
    print(f"Generated {total} SQL models.")
    print(f"  Staging:      {len(STG_MODELS)}")
    print(f"  Intermediate: {len(INT_MODELS)} ({len(EPHEMERAL_MODELS)} ephemeral)")
    print(f"  Marts:        {sum(len(v) for v in MART_MODELS.values())} across {len(DOMAINS)} domains")
    print(f"  Seeds:        {len(SEEDS)}")
    for d in ("tests", "analyses", "macros"):
        os.makedirs(os.path.join(BASE_DIR, d), exist_ok=True)
    print("Done!")


if __name__ == "__main__":
    main()
