select department_id, department_name, cost_center, head_count, budget
from {{ ref('stg_feature_usage_017') }}
