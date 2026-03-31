select channel_name, count(*) as total
from {{ ref('stg_users_095') }}
group by channel_name
