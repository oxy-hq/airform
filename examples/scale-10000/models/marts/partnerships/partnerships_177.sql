select department_name, count(*) as total
from {{ ref('stg_feature_usage_077') }}
group by department_name
