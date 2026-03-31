select order_id, count(*) as total
from {{ ref('stg_accounts_099') }}
group by order_id
