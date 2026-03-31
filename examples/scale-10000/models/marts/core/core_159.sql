select order_id, count(*) as total
from {{ ref('stg_accounts_059') }}
group by order_id
