select channel_name, count(*) as total
from {{ ref('stg_order_items_095') }}
group by channel_name
