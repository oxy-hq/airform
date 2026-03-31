select product_name, count(*) as total
from {{ ref('stg_campaigns_091') }}
group by product_name
