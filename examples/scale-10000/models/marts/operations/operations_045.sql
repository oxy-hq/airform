select invoice_id, count(*) as total
from {{ ref('stg_order_items_045') }}
group by invoice_id
