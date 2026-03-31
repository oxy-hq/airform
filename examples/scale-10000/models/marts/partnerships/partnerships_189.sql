select user_id, count(*) as total
from {{ ref('stg_feature_usage_089') }}
group by user_id
