select product_id, product_name, category, price, cost
from {{ ref('stg_feature_usage_051') }}
