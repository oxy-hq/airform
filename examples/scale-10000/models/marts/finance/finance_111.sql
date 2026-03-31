select product_name, count(*) as total
from {{ ref('stg_payments_011') }}
group by product_name
