select channel_name, count(*) as total
from {{ ref('stg_accounts_035') }}
group by channel_name
