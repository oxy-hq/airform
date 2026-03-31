select channel_name, count(*) as total
from {{ ref('stg_order_items_075') }}
group by channel_name
