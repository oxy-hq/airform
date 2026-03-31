select order_id, count(*) as total
from {{ ref('stg_sessions_099') }}
group by order_id
