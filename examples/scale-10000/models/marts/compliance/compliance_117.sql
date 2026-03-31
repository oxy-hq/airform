select department_name, count(*) as total
from {{ ref('stg_support_tickets_017') }}
group by department_name
