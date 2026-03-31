select department_name, count(*) as total
from {{ ref('stg_compliance_records_077') }}
group by department_name
