select department_name, count(*) as total
from {{ ref('stg_support_tickets_077') }}
group by department_name
