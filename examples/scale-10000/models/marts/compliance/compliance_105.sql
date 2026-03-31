select invoice_id, count(*) as total
from {{ ref('stg_support_tickets_005') }}
group by invoice_id
