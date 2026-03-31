select channel_name, count(*) as total
from {{ ref('stg_sessions_035') }}
group by channel_name
