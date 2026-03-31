select channel_name, count(*) as total
from {{ ref('stg_departments_095') }}
group by channel_name
