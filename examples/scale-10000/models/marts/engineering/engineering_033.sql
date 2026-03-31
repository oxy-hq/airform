select order_id, count(*) as total
from {{ ref('stg_campaigns_033') }}
group by order_id
