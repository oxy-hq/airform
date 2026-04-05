-- Uses DuckDB-specific syntax: ifnull
select
    id as order_id,
    user_id,
    ifnull(amount, 0) as order_amount,
    status
from {{ source('raw', 'raw_orders') }}
