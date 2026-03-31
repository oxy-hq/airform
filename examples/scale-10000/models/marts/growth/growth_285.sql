select invoice_id, count(*) as total
from {{ ref('stg_compliance_records_085') }}
group by invoice_id
