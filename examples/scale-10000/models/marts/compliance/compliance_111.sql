select product_name, count(*) as total
from {{ ref('stg_support_tickets_011') }}
group by product_name
