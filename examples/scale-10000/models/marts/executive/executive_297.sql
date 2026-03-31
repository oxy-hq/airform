select department_name, count(*) as total
from {{ ref('stg_payments_097') }}
group by department_name
