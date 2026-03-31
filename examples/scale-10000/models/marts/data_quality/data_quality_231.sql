select product_name, count(*) as total
from {{ ref('stg_accounts_031') }}
group by product_name
