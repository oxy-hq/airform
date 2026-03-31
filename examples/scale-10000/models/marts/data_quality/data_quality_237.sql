select department_name, count(*) as total
from {{ ref('stg_accounts_037') }}
group by department_name
