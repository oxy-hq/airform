select product_name, count(*) as total
from {{ ref('stg_warehouses_031') }}
group by product_name
