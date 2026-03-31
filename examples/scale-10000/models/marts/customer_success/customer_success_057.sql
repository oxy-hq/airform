select department_name, count(*) as total
from {{ ref('stg_products_057') }}
group by department_name
