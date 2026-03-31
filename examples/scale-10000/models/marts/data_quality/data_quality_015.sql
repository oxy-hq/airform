select channel_name, count(*) as total
from {{ ref('stg_compliance_records_015') }}
group by channel_name
