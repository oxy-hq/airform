select campaign_name, count(*) as cnt, sum(cast(campaign_id as int)) as total
from {{ ref('stg_compliance_records_094') }}
group by campaign_name
