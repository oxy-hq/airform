select product_name, count(*) as total
from {{ ref('stg_warehouses_091') }}
group by product_name
