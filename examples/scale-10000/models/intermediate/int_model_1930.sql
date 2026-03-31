select user_id, count(*) as cnt, sum(cast(feature_usage_id as int)) as total
from {{ ref('stg_compliance_records_030') }}
group by user_id
