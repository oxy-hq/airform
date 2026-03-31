select campaign_name, count(*) as cnt, sum(cast(campaign_id as int)) as total
from {{ ref('stg_invoices_054') }}
group by campaign_name
