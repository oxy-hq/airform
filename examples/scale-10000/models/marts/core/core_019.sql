select shipment_id, order_id, warehouse_id, shipped_at, delivered_at
from {{ ref('stg_users_019') }}
