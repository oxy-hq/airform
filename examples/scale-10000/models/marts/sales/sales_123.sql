select account_id, count(*) as total
from {{ ref('stg_compliance_records_023') }}
group by account_id
