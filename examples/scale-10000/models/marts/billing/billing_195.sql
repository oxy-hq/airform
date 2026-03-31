select channel_name, count(*) as total
from {{ ref('stg_sessions_095') }}
group by channel_name
