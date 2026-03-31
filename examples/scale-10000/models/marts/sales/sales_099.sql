select order_id, count(*) as total
from {{ ref('stg_shipments_099') }}
group by order_id
