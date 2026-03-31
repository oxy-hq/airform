select invoice_id, count(*) as total
from {{ ref('stg_payments_045') }}
group by invoice_id
