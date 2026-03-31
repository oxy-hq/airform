select account_id, count(*) as total
from {{ ref('stg_subscriptions_043') }}
group by account_id
