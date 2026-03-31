select invoice_id, count(*) as total
from {{ ref('stg_compliance_records_025') }}
group by invoice_id
