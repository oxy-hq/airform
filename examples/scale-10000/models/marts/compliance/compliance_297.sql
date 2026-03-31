select department_name, count(*) as total
from {{ ref('stg_feature_usage_097') }}
group by department_name
