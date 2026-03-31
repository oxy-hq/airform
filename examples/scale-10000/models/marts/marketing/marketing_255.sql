select channel_name, count(*) as total
from {{ ref('stg_support_tickets_055') }}
group by channel_name
