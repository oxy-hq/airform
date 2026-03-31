select order_id, count(*) as total
from {{ ref('stg_subscriptions_073') }}
group by order_id
