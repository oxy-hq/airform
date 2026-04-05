-- Uses ClickHouse-specific syntax: toFloat64 cast, ILIKE
select
    id,
    first_name,
    last_name,
    email,
    country,
    toFloat64(revenue) as revenue_amount
from {{ source('raw', 'raw_users') }}
where email ilike '%@example.com'
