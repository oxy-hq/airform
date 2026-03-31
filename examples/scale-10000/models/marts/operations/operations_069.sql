select user_id, count(*) as total
from {{ ref('stg_order_items_069') }}
group by user_id
