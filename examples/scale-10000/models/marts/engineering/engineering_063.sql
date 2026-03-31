select account_id, count(*) as total
from {{ ref('stg_campaigns_063') }}
group by account_id
