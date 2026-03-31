select product_name, count(*) as total
from {{ ref('stg_users_051') }}
group by product_name
