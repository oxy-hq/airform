select *,
    case when session_id = 'active' then 1 when session_id = 'inactive' then 0 else -1 end as session_id_flag,
    coalesce(session_id, 'unknown') as session_id_clean
from {{ ref('stg_orders_028') }}
