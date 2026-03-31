select department_name, count(*) as total
from {{ ref('stg_products_017') }}
group by department_name
