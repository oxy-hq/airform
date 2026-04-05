-- Uses SQLite-compatible syntax: CAST and LIKE (SQLite has no ILIKE)
select
    id,
    first_name,
    last_name,
    email,
    country,
    cast(revenue as real) as revenue_amount
from {{ source('raw', 'raw_users') }}
where lower(email) like '%@example.com'
