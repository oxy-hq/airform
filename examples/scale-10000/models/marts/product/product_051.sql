select product_name, count(*) as total
from {{ ref('stg_feature_usage_051') }}
group by product_name
