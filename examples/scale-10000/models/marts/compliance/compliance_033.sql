select order_id, count(*) as total
from {{ ref('stg_page_views_033') }}
group by order_id
