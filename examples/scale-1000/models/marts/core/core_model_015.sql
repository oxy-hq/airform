select
    channel_name,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_accounts_05') }}
group by channel_name
