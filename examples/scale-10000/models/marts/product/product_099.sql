select order_id, count(*) as total
from {{ ref('stg_feature_usage_099') }}
group by order_id
