select channel_name, count(*) as total
from {{ ref('stg_users_055') }}
group by channel_name
