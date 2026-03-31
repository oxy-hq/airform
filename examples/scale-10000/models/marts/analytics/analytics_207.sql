select user_id, count(*) as total
from {{ ref('stg_sessions_007') }}
group by user_id
