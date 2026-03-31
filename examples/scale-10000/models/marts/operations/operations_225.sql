select invoice_id, count(*) as total
from {{ ref('stg_channels_025') }}
group by invoice_id
