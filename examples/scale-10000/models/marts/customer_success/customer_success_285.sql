select invoice_id, count(*) as total
from {{ ref('stg_order_items_085') }}
group by invoice_id
