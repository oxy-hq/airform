select invoice_id, count(*) as total
from {{ ref('stg_channels_065') }}
group by invoice_id
