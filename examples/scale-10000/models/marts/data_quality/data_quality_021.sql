select account_id, count(*) as total
from {{ ref('stg_compliance_records_021') }}
group by account_id
