select subscription_id, account_id, plan_id, start_date, end_date
from {{ ref('stg_compliance_records_023') }}
