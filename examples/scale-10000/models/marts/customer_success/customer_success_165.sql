select invoice_id, count(*) as total
from {{ ref('stg_orders_065') }}
group by invoice_id
