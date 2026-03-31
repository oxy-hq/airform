select channel_name, count(*) as total
from {{ ref('stg_feature_usage_015') }}
group by channel_name
