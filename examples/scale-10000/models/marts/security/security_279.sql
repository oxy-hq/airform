select order_id, count(*) as total
from {{ ref('stg_shipments_079') }}
group by order_id
