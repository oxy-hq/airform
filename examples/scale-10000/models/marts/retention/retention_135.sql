select channel_name, count(*) as total
from {{ ref('stg_employees_035') }}
group by channel_name
