select account_id, count(*) as total
from {{ ref('stg_sessions_023') }}
group by account_id
