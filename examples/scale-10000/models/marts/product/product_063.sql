select account_id, count(*) as total
from {{ ref('stg_feature_usage_063') }}
group by account_id
