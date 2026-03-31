select department_name, count(*) as total
from {{ ref('stg_products_037') }}
group by department_name
