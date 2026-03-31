select user_id, count(*) as total
from {{ ref('stg_products_087') }}
group by user_id
