select product_name, count(*) as total
from {{ ref('stg_products_031') }}
group by product_name
