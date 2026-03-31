select
    order_id,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_compliance_records_09') }}
group by order_id
