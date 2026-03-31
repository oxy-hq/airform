select department_name, count(*) as total
from {{ ref('stg_shipments_017') }}
group by department_name
