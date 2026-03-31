select channel_name, count(*) as total
from {{ ref('stg_channels_055') }}
group by channel_name
