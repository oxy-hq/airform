select user_id, count(*) as total
from {{ ref('stg_events_047') }}
group by user_id
