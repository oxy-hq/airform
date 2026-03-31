select channel_name, count(*) as total
from {{ ref('stg_departments_035') }}
group by channel_name
