select department_name, count(*) as total
from {{ ref('stg_departments_037') }}
group by department_name
