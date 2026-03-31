select
    user_id,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_products_09') }}
group by user_id
