select user_id, count(*) as cnt, sum(cast(event_id as int)) as total
from {{ ref('stg_feature_usage_006') }}
group by user_id
