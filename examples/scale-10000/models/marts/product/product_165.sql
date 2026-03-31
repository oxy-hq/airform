select invoice_id, count(*) as total
from {{ ref('stg_products_065') }}
group by invoice_id
