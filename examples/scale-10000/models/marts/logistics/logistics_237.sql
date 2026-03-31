select department_name, count(*) as total
from {{ ref('stg_invoices_037') }}
group by department_name
