select account_id, count(*) as total
from {{ ref('stg_products_083') }}
group by account_id
