select order_item_id, order_id, product_id, quantity, unit_price
from {{ ref('stg_page_views_093') }}
