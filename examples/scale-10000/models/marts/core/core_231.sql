select product_name, count(*) as total
from {{ ref('stg_subscriptions_031') }}
group by product_name
