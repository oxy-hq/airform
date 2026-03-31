select channel_name, count(*) as total
from {{ ref('stg_accounts_075') }}
group by channel_name
