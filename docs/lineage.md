# Lineage

Airform provides both table-level and column-level lineage analysis. Lineage shows you the upstream dependencies and downstream dependents of any model in your project.

## Table-level lineage

Table-level lineage is derived from the `ref()` and `source()` calls in your SQL. It answers: "which models does this model depend on?" and "which models depend on this model?"

### Viewing upstream dependencies

```bash
airform lineage customers --upstream
```

This shows all models that `customers` depends on, directly or transitively:

```
customers
  <- stg_customers
  <- stg_orders
  <- stg_payments
    <- source:jaffle_shop.raw_customers
    <- source:jaffle_shop.raw_orders
    <- source:jaffle_shop.raw_payments
```

### Viewing downstream dependents

```bash
airform lineage stg_orders --downstream
```

This shows all models that depend on `stg_orders`:

```
stg_orders
  -> customers
  -> orders
```

### Viewing both directions

```bash
airform lineage stg_orders --upstream --downstream
```

If neither `--upstream` nor `--downstream` is specified, airform shows both directions by default.

## Column-level lineage

Column-level lineage traces how individual columns flow through your transformation DAG. Airform uses regex-based SQL analysis to extract column references from compiled SQL and map them to upstream models and sources.

### Tracing a column

```bash
airform lineage customers --column customer_lifetime_value
```

This traces the `customer_lifetime_value` column in the `customers` model back through the DAG:

```
customers.customer_lifetime_value
  <- stg_payments.amount (transform)
  <- stg_orders.order_id (scan)
  <- stg_orders.customer_id (copy)
```

### Dependency types

Column lineage edges are classified into three types:

| Type | Description | Example |
|------|-------------|---------|
| **copy** | Direct column pass-through | `SELECT customer_id FROM orders` |
| **transform** | Column used in an expression | `SELECT sum(amount) AS total` |
| **scan** | Column used in WHERE, JOIN, or GROUP BY | `WHERE status = 'active'` |

- **copy** means the column value flows through unchanged (possibly renamed via `AS`).
- **transform** means the column is an input to a computation (aggregation, arithmetic, function call).
- **scan** means the column is used for filtering or joining but does not directly produce an output column. Scan dependencies have `*` as their target column.

## How column lineage works

Airform's column lineage analysis (`airform-graph` crate) works as follows:

1. **Build alias map**: For each model, map CTE names and table aliases to their upstream model or source names using `ref()` and `source()` dependency information.

2. **Resolve multi-hop CTEs**: If a CTE `A` selects from CTE `B` which selects from model `C`, the alias map resolves `A` all the way to `C`.

3. **Parse SELECT columns**: The final SELECT block in each model is parsed to extract output column expressions and their aliases.

4. **Classify dependencies**: For each output column:
   - Qualified references (`table.column`) are mapped through the alias map to upstream sources.
   - Simple pass-through references are classified as `copy`.
   - Multi-source or expression-based references are classified as `transform`.

5. **Extract scan dependencies**: WHERE, JOIN ON, and GROUP BY clauses are analyzed for qualified column references, which are recorded as `scan` dependencies.

6. **Trace recursively**: The `trace_column` method follows lineage edges backward through the entire DAG, collecting the complete provenance chain.

## CLI usage summary

```bash
# Show upstream dependencies for a model
airform lineage <model> --upstream

# Show downstream dependents for a model
airform lineage <model> --downstream

# Trace a specific column through the DAG
airform lineage <model> --column <column_name>

# Combine options
airform lineage customers --upstream --column customer_id
```

## Limitations

- Column lineage uses regex-based SQL parsing rather than a full SQL parser. Complex expressions, subqueries, and window functions may not be fully traced.
- `SELECT *` blocks are skipped during lineage analysis since the specific columns cannot be determined without schema information.
- Unqualified column references (without a table alias) are resolved on a best-effort basis by checking which upstream model has a matching column definition.
