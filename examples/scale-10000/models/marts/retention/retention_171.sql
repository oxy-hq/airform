select product_name, count(*) as total
from {{ ref('stg_employees_071') }}
group by product_name
