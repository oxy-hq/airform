select channel_name, count(*) as total
from {{ ref('stg_users_035') }}
group by channel_name
