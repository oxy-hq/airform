select account_id, count(*) as total
from {{ ref('stg_warehouses_043') }}
group by account_id
