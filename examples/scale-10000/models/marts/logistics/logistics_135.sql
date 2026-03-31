select channel_name, count(*) as total
from {{ ref('stg_subscriptions_035') }}
group by channel_name
