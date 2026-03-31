select product_id, product_name, category, price, cost
from {{ ref('stg_products_011') }}
