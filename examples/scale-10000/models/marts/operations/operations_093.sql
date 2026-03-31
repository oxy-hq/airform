select order_id, count(*) as total
from {{ ref('stg_order_items_093') }}
group by order_id
