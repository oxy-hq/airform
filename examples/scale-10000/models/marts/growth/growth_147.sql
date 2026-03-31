select user_id, count(*) as total
from {{ ref('stg_shipments_047') }}
group by user_id
