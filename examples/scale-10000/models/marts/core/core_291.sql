select product_name, count(*) as total
from {{ ref('stg_subscriptions_091') }}
group by product_name
