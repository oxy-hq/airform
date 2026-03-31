select department_name, count(*) as total
from {{ ref('stg_users_037') }}
group by department_name
