# Models

Models are SQL `SELECT` statements that define transformations. Each `.sql` file in your model paths becomes a model, named after the file (without the `.sql` extension).

## Writing a model

Create a `.sql` file in your `models/` directory:

```sql
-- models/staging/stg_customers.sql
with source as (

    select * from {{ source('jaffle_shop', 'raw_customers') }}

),

renamed as (

    select
        id as customer_id,
        first_name,
        last_name

    from source

)

select * from renamed
```

## Referencing other models with ref()

Use `{{ ref('model_name') }}` to reference another model. Airform resolves this to the correct table/view name at compile time and automatically builds the dependency graph.

```sql
-- models/marts/customers.sql
with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

)

select
    customers.customer_id,
    customers.first_name,
    count(orders.order_id) as order_count
from customers
left join orders on customers.customer_id = orders.customer_id
group by customers.customer_id, customers.first_name
```

Cross-project refs are supported with an optional package argument:

```sql
select * from {{ ref('other_package', 'their_model') }}
```

## Referencing raw data with source()

Use `{{ source('source_name', 'table_name') }}` to reference raw tables defined in your `_sources.yml` files.

Define sources in a YAML file alongside your models:

```yaml
# models/staging/_sources.yml
version: 2

sources:
  - name: jaffle_shop
    schema: raw
    description: Raw data from the Jaffle Shop application database.
    tables:
      - name: raw_customers
        description: One record per customer.
      - name: raw_orders
        description: One record per order placed.
      - name: raw_payments
        description: One record per payment made.
```

Then reference them in SQL:

```sql
select * from {{ source('jaffle_shop', 'raw_customers') }}
```

At compile time, this resolves to `raw.raw_customers` (using the schema defined in the source).

## Materializations

Materializations control how a model is persisted in the execution context. Set the materialization in the model config or in `dbt_project.yml`.

### view (default)

The model is registered as a SQL view. It is not executed until queried. This is fast to create and always reflects the latest upstream data.

```sql
{{ config(materialized='view') }}

select * from {{ ref('stg_customers') }}
```

### table

The model SQL is executed and the results are stored as an in-memory table. Use this for models that are queried frequently or serve as input to multiple downstream models.

```sql
{{ config(materialized='table') }}

select * from {{ ref('stg_orders') }}
```

### incremental

Similar to table, but designed for append-only or merge workloads. In local execution, incremental models are treated the same as tables (full refresh). Use `--full-refresh` to force a complete rebuild.

```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge'
) }}

select * from {{ ref('stg_orders') }}
{% if is_incremental() %}
    where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

### ephemeral

Ephemeral models are not executed directly. Instead, their SQL is injected as a Common Table Expression (CTE) into any downstream model that references them. Use ephemeral for lightweight helper transformations.

```sql
{{ config(materialized='ephemeral') }}

select
    id as customer_id,
    first_name || ' ' || last_name as full_name
from {{ source('jaffle_shop', 'raw_customers') }}
```

When a downstream model does `{{ ref('this_model') }}`, the SQL above is inlined as `__dbt__cte__this_model`.

## Model configuration with config()

Use the `config()` Jinja block at the top of a model to set configuration:

```sql
{{ config(
    materialized='table',
    schema='marts',
    alias='dim_customers',
    tags=['daily', 'core'],
    enabled=true,
    meta={'owner': 'analytics'}
) }}

select * from {{ ref('stg_customers') }}
```

### Available config properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `materialized` | string | `view` | `view`, `table`, `incremental`, or `ephemeral` |
| `schema` | string | target schema | Custom schema for this model |
| `database` | string | target database | Custom database for this model |
| `alias` | string | model filename | Custom table/view name |
| `tags` | list | `[]` | Tags for node selection |
| `enabled` | boolean | `true` | Set to `false` to skip this model |
| `unique_key` | string | none | Unique key column(s) for incremental models |
| `incremental_strategy` | string | none | Strategy for incremental models |
| `on_schema_change` | string | none | Behavior when schema changes (incremental) |

## Configuring models in dbt_project.yml

You can set defaults for groups of models based on their directory path:

```yaml
models:
  my_project:
    +materialized: view          # Default for all models
    staging:
      +materialized: view        # models/staging/*
      +tags: ["staging"]
    marts:
      +materialized: table       # models/marts/*
      +tags: ["marts"]
```

In-model `config()` blocks always take precedence over `dbt_project.yml` settings.

## Documenting models in schema.yml

Create `_schema.yml` (or any `.yml`) files alongside your models to add descriptions and tests:

```yaml
version: 2

models:
  - name: customers
    description: >
      Customer-level table with lifetime order summary metrics.
      One row per customer.
    columns:
      - name: customer_id
        description: Primary key.
        tests:
          - not_null
          - unique
      - name: first_name
        description: Customer's first name.
      - name: customer_lifetime_value
        description: Total amount spent across all orders.
```

## Selecting specific models

Use `--select` (or `-s`) to run or compile specific models:

```bash
# Run a single model
airform run --select customers

# Run all models in a directory
airform run --select staging

# Exclude specific models
airform run --exclude stg_payments
```

## Execution order

Airform builds a directed acyclic graph (DAG) from your `ref()` and `source()` calls, then executes models in topological order. A model is never executed before its dependencies.
