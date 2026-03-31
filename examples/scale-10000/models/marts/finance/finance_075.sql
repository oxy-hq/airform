select channel_name, count(*) as total
from {{ ref('stg_invoices_075') }}
group by channel_name
