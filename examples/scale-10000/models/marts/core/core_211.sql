select product_id, product_name, category, price, cost
from {{ ref('stg_subscriptions_011') }}
