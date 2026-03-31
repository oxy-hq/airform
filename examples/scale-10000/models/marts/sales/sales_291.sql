select product_name, count(*) as total
from {{ ref('stg_users_091') }}
group by product_name
