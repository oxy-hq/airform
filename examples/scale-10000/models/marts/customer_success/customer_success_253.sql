select order_item_id, order_id, product_id, quantity, unit_price
from {{ ref('stg_order_items_053') }}
