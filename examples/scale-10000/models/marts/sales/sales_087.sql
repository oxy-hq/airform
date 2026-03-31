select user_id, count(*) as total
from {{ ref('stg_shipments_087') }}
group by user_id
