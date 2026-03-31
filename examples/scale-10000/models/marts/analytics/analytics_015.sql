select channel_name, count(*) as total
from {{ ref('stg_payments_015') }}
group by channel_name
