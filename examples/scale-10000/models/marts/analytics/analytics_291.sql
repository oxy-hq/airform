select product_name, count(*) as total
from {{ ref('stg_sessions_091') }}
group by product_name
