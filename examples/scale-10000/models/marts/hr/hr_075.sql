select channel_name, count(*) as total
from {{ ref('stg_employees_075') }}
group by channel_name
