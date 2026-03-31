select product_name, count(*) as total
from {{ ref('stg_products_091') }}
group by product_name
