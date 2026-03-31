select channel_name, count(*) as total
from {{ ref('stg_page_views_015') }}
group by channel_name
