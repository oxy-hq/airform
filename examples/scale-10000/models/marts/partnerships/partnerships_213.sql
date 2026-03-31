select order_id, count(*) as total
from {{ ref('stg_products_013') }}
group by order_id
