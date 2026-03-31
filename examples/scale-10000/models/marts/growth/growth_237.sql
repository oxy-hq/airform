select department_name, count(*) as total
from {{ ref('stg_compliance_records_037') }}
group by department_name
