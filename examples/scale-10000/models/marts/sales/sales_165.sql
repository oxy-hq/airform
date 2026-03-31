select invoice_id, count(*) as total
from {{ ref('stg_compliance_records_065') }}
group by invoice_id
