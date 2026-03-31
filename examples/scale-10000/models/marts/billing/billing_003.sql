select account_id, count(*) as total
from {{ ref('stg_events_003') }}
group by account_id
