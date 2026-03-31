select user_id, count(*) as total
from {{ ref('stg_support_tickets_007') }}
group by user_id
