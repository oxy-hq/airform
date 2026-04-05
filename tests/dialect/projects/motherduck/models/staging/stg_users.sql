-- Uses DuckDB-specific syntax: :: cast and ILIKE
select
    id,
    first_name,
    last_name,
    email,
    country,
    revenue::double as revenue_amount
from {{ source('raw', 'raw_users') }}
where email ilike '%@example.com'
