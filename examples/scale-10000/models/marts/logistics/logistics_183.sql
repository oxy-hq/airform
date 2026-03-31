select account_id, count(*) as total
from {{ ref('stg_subscriptions_083') }}
group by account_id
