-- Uses SQLite-compatible syntax: coalesce (SQLite has no ifnull as a standard fn)
select
    id as order_id,
    user_id,
    coalesce(amount, 0) as order_amount,
    status
from {{ source('raw', 'raw_orders') }}
