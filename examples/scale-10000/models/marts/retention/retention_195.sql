select channel_name, count(*) as total
from {{ ref('stg_employees_095') }}
group by channel_name
