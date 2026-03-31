select
    account_id,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_channels_03') }}
group by account_id
