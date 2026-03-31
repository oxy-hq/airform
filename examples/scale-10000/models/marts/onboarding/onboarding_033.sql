select order_id, count(*) as total
from {{ ref('stg_orders_033') }}
group by order_id
