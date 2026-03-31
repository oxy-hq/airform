select user_id, count(*) as total
from {{ ref('stg_sessions_029') }}
group by user_id
