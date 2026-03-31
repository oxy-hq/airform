select invoice_id, count(*) as total
from {{ ref('stg_invoices_005') }}
group by invoice_id
