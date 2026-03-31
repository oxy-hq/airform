select channel_name, count(*) as total
from {{ ref('stg_accounts_055') }}
group by channel_name
