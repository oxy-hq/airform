select product_name, count(*) as total
from {{ ref('stg_sessions_051') }}
group by product_name
