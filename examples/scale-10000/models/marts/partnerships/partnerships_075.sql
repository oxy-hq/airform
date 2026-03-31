select channel_name, count(*) as total
from {{ ref('stg_support_tickets_075') }}
group by channel_name
