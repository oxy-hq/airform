select order_id, count(*) as total
from {{ ref('stg_products_079') }}
group by order_id
