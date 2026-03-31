select channel_name, count(*) as total
from {{ ref('stg_shipments_035') }}
group by channel_name
