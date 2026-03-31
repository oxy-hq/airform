select account_id, count(*) as total
from {{ ref('stg_products_063') }}
group by account_id
