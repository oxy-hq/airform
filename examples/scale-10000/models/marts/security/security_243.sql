select account_id, count(*) as total
from {{ ref('stg_shipments_043') }}
group by account_id
