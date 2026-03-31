select product_name, count(*) as total
from {{ ref('stg_feature_usage_071') }}
group by product_name
