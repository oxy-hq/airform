select department_name, count(*) as total
from {{ ref('stg_payments_017') }}
group by department_name
