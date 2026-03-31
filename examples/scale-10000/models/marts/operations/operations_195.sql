select channel_name, count(*) as total
from {{ ref('stg_campaigns_095') }}
group by channel_name
