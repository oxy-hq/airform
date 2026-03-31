select invoice_id, count(*) as total
from {{ ref('stg_products_005') }}
group by invoice_id
