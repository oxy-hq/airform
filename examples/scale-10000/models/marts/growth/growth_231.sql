select product_name, count(*) as total
from {{ ref('stg_compliance_records_031') }}
group by product_name
