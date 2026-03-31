select product_name, count(*) as total
from {{ ref('stg_events_071') }}
group by product_name
