select account_id, count(*) as total
from {{ ref('stg_feature_usage_061') }}
group by account_id
