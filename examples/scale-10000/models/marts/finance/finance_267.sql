select user_id, count(*) as total
from {{ ref('stg_events_067') }}
group by user_id
