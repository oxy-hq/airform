select product_name, count(*) as total
from {{ ref('stg_accounts_091') }}
group by product_name
