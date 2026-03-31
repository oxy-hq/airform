select order_id, count(*) as total
from {{ ref('stg_sessions_019') }}
group by order_id
