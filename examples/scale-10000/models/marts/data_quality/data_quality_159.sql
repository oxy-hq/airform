select order_id, count(*) as total
from {{ ref('stg_users_059') }}
group by order_id
