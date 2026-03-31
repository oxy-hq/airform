select department_name, count(*) as total
from {{ ref('stg_departments_017') }}
group by department_name
