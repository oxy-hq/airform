select account_id, count(*) as total
from {{ ref('stg_events_061') }}
group by account_id
