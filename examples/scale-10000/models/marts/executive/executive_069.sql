select user_id, count(*) as total
from {{ ref('stg_subscriptions_069') }}
group by user_id
