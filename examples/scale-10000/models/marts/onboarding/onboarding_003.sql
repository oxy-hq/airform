select account_id, count(*) as total
from {{ ref('stg_orders_003') }}
group by account_id
