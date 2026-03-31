select user_id, count(*) as total
from {{ ref('stg_users_029') }}
group by user_id
