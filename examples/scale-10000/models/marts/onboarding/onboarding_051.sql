select product_name, count(*) as total
from {{ ref('stg_orders_051') }}
group by product_name
