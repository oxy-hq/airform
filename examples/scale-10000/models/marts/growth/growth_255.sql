select channel_name, count(*) as total
from {{ ref('stg_compliance_records_055') }}
group by channel_name
