select department_name, count(*) as total
from {{ ref('stg_compliance_records_097') }}
group by department_name
