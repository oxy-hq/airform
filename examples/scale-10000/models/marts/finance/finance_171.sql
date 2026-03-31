select product_name, count(*) as total
from {{ ref('stg_payments_071') }}
group by product_name
