select user_id, count(*) as total
from {{ ref('stg_page_views_029') }}
group by user_id
