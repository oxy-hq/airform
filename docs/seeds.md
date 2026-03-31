# Seeds

Seeds are CSV files in your project that airform loads into the execution context as tables. They are useful for small, static datasets such as lookup tables, mapping files, or test fixtures.

## Adding a seed

Place a `.csv` file in your `seeds/` directory (or whichever directories are configured in `seed-paths`):

```
seeds/
  raw_customers.csv
  raw_orders.csv
  raw_payments.csv
```

Each CSV file must have a header row:

```csv
id,first_name,last_name
1,Michael,P.
2,Shawn,M.
3,Kathleen,P.
```

## Loading seeds

Run the `seed` command to register all CSV files as tables in the DataFusion context:

```bash
airform seed
```

Output:

```
Loaded seed: raw_customers (100 rows)
Loaded seed: raw_orders (99 rows)
Loaded seed: raw_payments (113 rows)
```

Seeds are automatically loaded before model execution when you run `airform run`, so you typically do not need to run `airform seed` separately. However, running it explicitly is useful for verifying that your CSVs parse correctly.

## Referencing seeds in models

Seeds are registered as tables and can be referenced using `source()` in your models, or directly by table name in compiled SQL. The typical pattern is to define them as sources:

```yaml
# models/staging/_sources.yml
version: 2

sources:
  - name: jaffle_shop
    schema: raw
    tables:
      - name: raw_customers
      - name: raw_orders
      - name: raw_payments
```

```sql
-- models/staging/stg_customers.sql
select * from {{ source('jaffle_shop', 'raw_customers') }}
```

## Seed configuration

Configure seeds in `dbt_project.yml`:

```yaml
seeds:
  my_project:
    +schema: raw              # Register seeds under the "raw" schema
```

### Configuration options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `schema` | string | target schema | Schema to register the seed table under |
| `tags` | list | `[]` | Tags for selection and organization |
| `enabled` | boolean | `true` | Whether to load this seed |

## CSV format requirements

- The first row must be a header with column names.
- Airform uses DataFusion's CSV reader with `has_header(true)`.
- Column types are inferred automatically from the data.
- Standard CSV quoting and escaping rules apply.

## Best practices

- Keep seed files small. Seeds are loaded into memory, so they are best for reference data (hundreds to low thousands of rows), not large datasets.
- Use seeds for data that changes infrequently: country codes, status mappings, category hierarchies.
- Version your seed CSVs in git alongside your SQL models.
- For large or frequently changing data, use sources that point to external tables instead.
