select user_id, count(*) as total
from {{ ref('stg_accounts_009') }}
group by user_id
