# Tests

Airform supports generic (schema) tests that validate data quality assertions on your models. Tests are defined in `_schema.yml` files alongside your models and executed against the DataFusion context after models have been built.

## Running tests

```bash
# Run all tests
airform test

# Run tests for specific models
airform test --select customers

# Run tests against a specific target
airform test --target prod
```

## Defining tests in schema.yml

Tests are declared on columns within your model definitions:

```yaml
version: 2

models:
  - name: stg_orders
    columns:
      - name: order_id
        tests:
          - not_null
          - unique
      - name: status
        tests:
          - accepted_values:
              values: ["placed", "shipped", "completed", "return_pending", "returned"]
```

## Generic test types

### not_null

Asserts that a column contains no `NULL` values.

```yaml
columns:
  - name: customer_id
    tests:
      - not_null
```

Generated SQL:

```sql
SELECT count(*) as failures
FROM my_model
WHERE customer_id IS NULL
```

The test passes if the failure count is 0.

### unique

Asserts that a column contains no duplicate values.

```yaml
columns:
  - name: order_id
    tests:
      - unique
```

Generated SQL:

```sql
SELECT order_id, count(*) as n
FROM my_model
GROUP BY order_id
HAVING count(*) > 1
```

The test passes if zero rows are returned (no duplicates found).

### accepted_values

Asserts that every non-null value in a column is within a specified set.

```yaml
columns:
  - name: status
    tests:
      - accepted_values:
          values: ["placed", "shipped", "completed", "return_pending", "returned"]
```

Generated SQL:

```sql
SELECT status
FROM my_model
WHERE status NOT IN ('placed', 'shipped', 'completed', 'return_pending', 'returned')
```

The test passes if zero rows are returned.

### relationships

Asserts referential integrity -- every non-null value in a column exists in a column of another model.

```yaml
columns:
  - name: customer_id
    tests:
      - relationships:
          to: ref('stg_customers')
          field: customer_id
```

Generated SQL:

```sql
SELECT customer_id
FROM my_model
WHERE customer_id IS NOT NULL
  AND customer_id NOT IN (SELECT customer_id FROM stg_customers)
```

The test passes if zero rows are returned (all foreign keys resolve).

## Test results

When you run `airform test`, each test reports one of three statuses:

| Status | Meaning |
|--------|---------|
| **PASS** | Zero failures found. The assertion holds. |
| **FAIL** | One or more failures found. The data violates the assertion. |
| **ERROR** | The test SQL could not be executed (e.g., the model does not exist or has a SQL error). |

Example output:

```
PASS  not_null_stg_orders_order_id         (0 failures)  0.002s
PASS  unique_stg_orders_order_id           (0 failures)  0.003s
PASS  accepted_values_stg_orders_status    (0 failures)  0.001s
FAIL  not_null_customers_email             (3 failures)  0.002s
```

## Complete example

Here is a full `_schema.yml` with multiple test types:

```yaml
version: 2

models:
  - name: customers
    description: Customer-level table with lifetime metrics.
    columns:
      - name: customer_id
        description: Primary key.
        tests:
          - not_null
          - unique
      - name: first_name
        description: Customer's first name.
      - name: number_of_orders
        description: Total orders placed.

  - name: orders
    description: Order-level table.
    columns:
      - name: order_id
        description: Primary key.
        tests:
          - not_null
          - unique
      - name: customer_id
        description: Foreign key to customers.
        tests:
          - not_null
          - relationships:
              to: ref('stg_customers')
              field: customer_id
      - name: status
        tests:
          - accepted_values:
              values: ["placed", "shipped", "completed", "return_pending", "returned"]
```

## Test execution order

Tests run after all models have been executed. Airform:

1. Loads seeds into the DataFusion context.
2. Compiles and executes all models in dependency order.
3. Iterates through all models with column-level test definitions.
4. Generates and executes the test SQL for each test.
5. Reports results.

## Best practices

- Add `not_null` and `unique` tests to every primary key column.
- Use `relationships` tests to verify foreign key integrity between models.
- Use `accepted_values` for columns with known, finite value sets (statuses, categories, types).
- Run `airform test` in CI to catch data quality regressions before they reach production.
