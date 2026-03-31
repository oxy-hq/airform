select user_id, count(*) as total
from {{ ref('stg_products_067') }}
group by user_id
