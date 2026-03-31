select invoice_id, count(*) as total
from {{ ref('stg_page_views_025') }}
group by invoice_id
