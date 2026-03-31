select channel_name, count(*) as total
from {{ ref('stg_events_095') }}
group by channel_name
