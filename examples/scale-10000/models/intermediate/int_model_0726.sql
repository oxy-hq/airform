select user_id, count(*) as cnt, sum(cast(event_id as int)) as total
from {{ ref('stg_page_views_026') }}
group by user_id
