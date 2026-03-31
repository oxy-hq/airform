select account_id, count(*) as total
from {{ ref('stg_compliance_records_061') }}
group by account_id
