select user_id, count(*) as total
from {{ ref('stg_events_009') }}
group by user_id
