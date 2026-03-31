select department_name, count(*) as total
from {{ ref('stg_sessions_097') }}
group by department_name
