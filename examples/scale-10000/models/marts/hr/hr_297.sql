select department_name, count(*) as total
from {{ ref('stg_warehouses_097') }}
group by department_name
