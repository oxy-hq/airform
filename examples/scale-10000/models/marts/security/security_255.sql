select channel_name, count(*) as total
from {{ ref('stg_shipments_055') }}
group by channel_name
