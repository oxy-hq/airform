select *, row_number() over (partition by channel_name order by channel_id) as rn
from {{ ref('stg_departments_015') }}
