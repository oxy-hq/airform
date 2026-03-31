select order_id, count(*) as total
from {{ ref('stg_sessions_059') }}
group by order_id
