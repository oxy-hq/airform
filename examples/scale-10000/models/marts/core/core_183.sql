select account_id, count(*) as total
from {{ ref('stg_accounts_083') }}
group by account_id
