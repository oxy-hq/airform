select invoice_id, count(*) as total
from {{ ref('stg_support_tickets_065') }}
group by invoice_id
