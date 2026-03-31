select account_id, count(*) as total
from {{ ref('stg_products_043') }}
group by account_id
