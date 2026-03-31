select department_name, count(*) as total
from {{ ref('stg_employees_057') }}
group by department_name
