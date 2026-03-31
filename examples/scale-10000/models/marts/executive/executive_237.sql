select department_name, count(*) as total
from {{ ref('stg_payments_037') }}
group by department_name
