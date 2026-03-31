select department_name, count(*) as total
from {{ ref('stg_feature_usage_057') }}
group by department_name
