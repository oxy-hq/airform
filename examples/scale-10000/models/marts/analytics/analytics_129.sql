select user_id, count(*) as total
from {{ ref('stg_events_029') }}
group by user_id
