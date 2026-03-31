select department_name, count(*) as total
from {{ ref('stg_users_017') }}
group by department_name
