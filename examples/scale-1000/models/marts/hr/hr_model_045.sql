select
    invoice_id,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_channels_05') }}
group by invoice_id
