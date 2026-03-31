select department_name, count(*) as total
from {{ ref('stg_channels_057') }}
group by department_name
