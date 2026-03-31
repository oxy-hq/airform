select product_name, count(*) as total
from {{ ref('stg_order_items_091') }}
group by product_name
