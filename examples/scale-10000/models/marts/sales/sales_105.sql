select invoice_id, count(*) as total
from {{ ref('stg_compliance_records_005') }}
group by invoice_id
