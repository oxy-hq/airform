select user_id, count(*) as total
from {{ ref('stg_accounts_007') }}
group by user_id
