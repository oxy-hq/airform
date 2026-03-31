select product_name, count(*) as total
from {{ ref('stg_users_071') }}
group by product_name
