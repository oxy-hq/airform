select invoice_id, count(*) as total
from {{ ref('stg_invoices_025') }}
group by invoice_id
