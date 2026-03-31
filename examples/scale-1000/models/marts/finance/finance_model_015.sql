select
    channel_name,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_page_views_05') }}
group by channel_name
