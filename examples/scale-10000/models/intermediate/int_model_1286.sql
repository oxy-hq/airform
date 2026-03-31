select user_id, count(*) as cnt, sum(cast(event_id as int)) as total
from {{ ref('stg_order_items_086') }}
group by user_id
