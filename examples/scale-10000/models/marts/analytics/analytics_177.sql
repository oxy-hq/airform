select department_name, count(*) as total
from {{ ref('stg_events_077') }}
group by department_name
