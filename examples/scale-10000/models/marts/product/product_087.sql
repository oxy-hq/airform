select user_id, count(*) as total
from {{ ref('stg_feature_usage_087') }}
group by user_id
