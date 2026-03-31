select department_name, count(*) as total
from {{ ref('stg_campaigns_057') }}
group by department_name
