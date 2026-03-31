select channel_name, count(*) as total
from {{ ref('stg_products_095') }}
group by channel_name
