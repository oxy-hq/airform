select invoice_id, count(*) as total
from {{ ref('stg_order_items_065') }}
group by invoice_id
