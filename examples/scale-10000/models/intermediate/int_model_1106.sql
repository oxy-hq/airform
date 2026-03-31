select user_id, count(*) as cnt, sum(cast(event_id as int)) as total
from {{ ref('stg_orders_006') }}
group by user_id
