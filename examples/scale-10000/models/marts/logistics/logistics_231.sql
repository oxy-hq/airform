select product_name, count(*) as total
from {{ ref('stg_invoices_031') }}
group by product_name
