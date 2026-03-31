select invoice_id, count(*) as total
from {{ ref('stg_products_085') }}
group by invoice_id
