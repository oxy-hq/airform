select department_name, count(*) as total
from {{ ref('stg_events_057') }}
group by department_name
