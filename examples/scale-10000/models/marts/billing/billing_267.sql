select user_id, count(*) as total
from {{ ref('stg_page_views_067') }}
group by user_id
