select department_name, count(*) as total
from {{ ref('stg_departments_097') }}
group by department_name
