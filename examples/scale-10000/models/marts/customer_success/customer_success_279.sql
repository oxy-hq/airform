select order_id, count(*) as total
from {{ ref('stg_order_items_079') }}
group by order_id
