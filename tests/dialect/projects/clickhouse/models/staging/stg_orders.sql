-- Uses ClickHouse-specific syntax: ifNull
select
    id as order_id,
    user_id,
    ifNull(amount, 0) as order_amount,
    status
from {{ source('raw', 'raw_orders') }}
