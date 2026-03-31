select department_name, count(*) as total
from {{ ref('stg_shipments_077') }}
group by department_name
