select invoice_id, count(*) as total
from {{ ref('stg_channels_045') }}
group by invoice_id
