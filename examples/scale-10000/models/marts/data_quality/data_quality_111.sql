select product_name, count(*) as total
from {{ ref('stg_users_011') }}
group by product_name
