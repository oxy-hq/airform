select account_id, count(*) as total
from {{ ref('stg_feature_usage_043') }}
group by account_id
