select product_name, count(*) as total
from {{ ref('stg_warehouses_071') }}
group by product_name
