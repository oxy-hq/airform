select department_name, count(*) as total
from {{ ref('stg_accounts_097') }}
group by department_name
