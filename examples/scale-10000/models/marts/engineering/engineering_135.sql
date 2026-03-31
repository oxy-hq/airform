select channel_name, count(*) as total
from {{ ref('stg_channels_035') }}
group by channel_name
