select user_id, count(*) as total
from {{ ref('stg_shipments_027') }}
group by user_id
