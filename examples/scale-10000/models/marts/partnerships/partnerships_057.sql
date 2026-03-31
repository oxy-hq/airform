select department_name, count(*) as total
from {{ ref('stg_support_tickets_057') }}
group by department_name
