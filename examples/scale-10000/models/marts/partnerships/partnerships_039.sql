select order_id, count(*) as total
from {{ ref('stg_support_tickets_039') }}
group by order_id
