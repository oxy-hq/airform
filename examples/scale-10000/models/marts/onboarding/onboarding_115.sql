select channel_id, channel_name, channel_type, is_active, created_at
from {{ ref('stg_order_items_015') }}
