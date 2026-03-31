select user_id, account_id, email, first_name, last_name
from {{ ref('stg_subscriptions_061') }}
