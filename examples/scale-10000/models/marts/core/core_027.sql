select user_id, count(*) as total
from {{ ref('stg_users_027') }}
group by user_id
