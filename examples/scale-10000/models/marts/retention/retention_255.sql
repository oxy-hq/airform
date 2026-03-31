select channel_name, count(*) as total
from {{ ref('stg_departments_055') }}
group by channel_name
