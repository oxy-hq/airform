select order_id, count(*) as total
from {{ ref('stg_products_073') }}
group by order_id
