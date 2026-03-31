select account_id, count(*) as total
from {{ ref('stg_accounts_041') }}
group by account_id
