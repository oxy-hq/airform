select campaign_name, count(*) as cnt, sum(cast(campaign_id as int)) as total
from {{ ref('stg_subscriptions_034') }}
group by campaign_name
