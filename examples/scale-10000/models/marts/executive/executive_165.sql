select invoice_id, count(*) as total
from {{ ref('stg_invoices_065') }}
group by invoice_id
