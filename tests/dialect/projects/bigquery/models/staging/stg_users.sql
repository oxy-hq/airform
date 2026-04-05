-- Uses BigQuery-specific syntax: backtick identifiers, IFNULL
select
    id,
    first_name,
    last_name,
    email,
    country,
    ifnull(revenue, 0) as revenue_amount
from {{ source('raw', 'raw_users') }}
