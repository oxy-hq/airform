select user_id, count(*) as total
from {{ ref('stg_page_views_007') }}
group by user_id
