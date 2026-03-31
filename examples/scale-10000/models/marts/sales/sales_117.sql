select department_name, count(*) as total
from {{ ref('stg_compliance_records_017') }}
group by department_name
