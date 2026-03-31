select user_id, count(*) as total
from {{ ref('stg_products_009') }}
group by user_id
