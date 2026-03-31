select channel_name, count(*) as total
from {{ ref('stg_invoices_095') }}
group by channel_name
