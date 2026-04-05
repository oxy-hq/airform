-- Uses Snowflake-specific syntax: NVL
select
    id as order_id,
    user_id,
    nvl(amount, 0) as order_amount,
    status
from {{ source('raw', 'raw_orders') }}
