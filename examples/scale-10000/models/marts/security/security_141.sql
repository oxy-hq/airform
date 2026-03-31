select account_id, count(*) as total
from {{ ref('stg_warehouses_041') }}
group by account_id
