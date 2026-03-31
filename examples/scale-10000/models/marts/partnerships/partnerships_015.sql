select channel_name, count(*) as total
from {{ ref('stg_support_tickets_015') }}
group by channel_name
