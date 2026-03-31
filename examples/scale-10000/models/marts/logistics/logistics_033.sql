select order_id, count(*) as total
from {{ ref('stg_accounts_033') }}
group by order_id
