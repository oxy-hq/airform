select product_name, count(*) as total
from {{ ref('stg_compliance_records_051') }}
group by product_name
