select account_id, count(*) as total
from {{ ref('stg_events_023') }}
group by account_id
