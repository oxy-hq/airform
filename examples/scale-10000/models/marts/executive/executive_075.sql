select channel_name, count(*) as total
from {{ ref('stg_subscriptions_075') }}
group by channel_name
