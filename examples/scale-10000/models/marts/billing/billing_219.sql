select order_id, count(*) as total
from {{ ref('stg_page_views_019') }}
group by order_id
