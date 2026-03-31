select channel_name, count(*) as total
from {{ ref('stg_products_015') }}
group by channel_name
