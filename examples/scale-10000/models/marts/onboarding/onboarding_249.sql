select user_id, count(*) as total
from {{ ref('stg_campaigns_049') }}
group by user_id
