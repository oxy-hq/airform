select invoice_id, count(*) as total
from {{ ref('stg_orders_005') }}
group by invoice_id
