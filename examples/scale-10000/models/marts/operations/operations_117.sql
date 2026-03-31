select department_name, count(*) as total
from {{ ref('stg_campaigns_017') }}
group by department_name
