select invoice_id, count(*) as total
from {{ ref('stg_products_025') }}
group by invoice_id
