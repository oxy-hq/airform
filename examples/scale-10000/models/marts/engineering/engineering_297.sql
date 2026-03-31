select department_name, count(*) as total
from {{ ref('stg_employees_097') }}
group by department_name
