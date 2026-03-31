select order_id, count(*) as total
from {{ ref('stg_compliance_records_073') }}
group by order_id
