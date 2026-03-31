select channel_name, count(*) as total
from {{ ref('stg_accounts_095') }}
group by channel_name
