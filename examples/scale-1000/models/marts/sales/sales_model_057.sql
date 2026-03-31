select
    department_name,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_accounts_07') }}
group by department_name
