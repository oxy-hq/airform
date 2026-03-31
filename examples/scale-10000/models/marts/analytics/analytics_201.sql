select account_id, count(*) as total
from {{ ref('stg_sessions_001') }}
group by account_id
