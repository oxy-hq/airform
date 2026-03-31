select department_name, count(*) as total
from {{ ref('stg_invoices_017') }}
group by department_name
