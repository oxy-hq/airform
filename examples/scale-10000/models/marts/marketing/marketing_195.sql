select channel_name, count(*) as total
from {{ ref('stg_page_views_095') }}
group by channel_name
