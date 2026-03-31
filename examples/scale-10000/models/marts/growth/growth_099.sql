select order_id, count(*) as total
from {{ ref('stg_warehouses_099') }}
group by order_id
