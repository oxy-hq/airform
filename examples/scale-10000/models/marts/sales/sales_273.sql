select order_id, count(*) as total
from {{ ref('stg_users_073') }}
group by order_id
