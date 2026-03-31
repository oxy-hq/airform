select user_id, count(*) as total
from {{ ref('stg_compliance_records_049') }}
group by user_id
