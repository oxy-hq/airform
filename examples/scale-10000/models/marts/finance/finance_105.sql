select invoice_id, count(*) as total
from {{ ref('stg_payments_005') }}
group by invoice_id
