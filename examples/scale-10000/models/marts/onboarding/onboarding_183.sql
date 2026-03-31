select account_id, count(*) as total
from {{ ref('stg_order_items_083') }}
group by account_id
