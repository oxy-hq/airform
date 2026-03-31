select user_id, count(*) as total
from {{ ref('stg_subscriptions_027') }}
group by user_id
