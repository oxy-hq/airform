select invoice_id, count(*) as total
from {{ ref('stg_employees_025') }}
group by invoice_id
