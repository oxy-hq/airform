select account_id, count(*) as total
from {{ ref('stg_shipments_001') }}
group by account_id
