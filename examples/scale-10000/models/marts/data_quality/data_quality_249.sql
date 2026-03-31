select user_id, count(*) as total
from {{ ref('stg_accounts_049') }}
group by user_id
