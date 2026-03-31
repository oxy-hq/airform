select
    product_name,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_orders_01') }}
group by product_name
