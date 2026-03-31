select account_name, count(*) as cnt, sum(cast(account_id as int)) as total
from {{ ref('stg_compliance_records_022') }}
group by account_name
