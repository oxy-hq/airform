select channel_name, count(*) as total
from {{ ref('stg_compliance_records_035') }}
group by channel_name
