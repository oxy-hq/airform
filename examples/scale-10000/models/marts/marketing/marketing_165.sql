select invoice_id, count(*) as total
from {{ ref('stg_page_views_065') }}
group by invoice_id
