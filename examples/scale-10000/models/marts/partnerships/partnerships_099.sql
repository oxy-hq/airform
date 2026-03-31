select order_id, count(*) as total
from {{ ref('stg_support_tickets_099') }}
group by order_id
