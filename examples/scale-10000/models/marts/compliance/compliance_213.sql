select order_id, count(*) as total
from {{ ref('stg_feature_usage_013') }}
group by order_id
