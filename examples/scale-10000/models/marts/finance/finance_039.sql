select order_id, count(*) as total
from {{ ref('stg_invoices_039') }}
group by order_id
