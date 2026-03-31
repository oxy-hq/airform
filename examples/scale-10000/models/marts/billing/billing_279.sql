select order_id, count(*) as total
from {{ ref('stg_page_views_079') }}
group by order_id
