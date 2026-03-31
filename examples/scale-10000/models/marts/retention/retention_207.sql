select user_id, count(*) as total
from {{ ref('stg_departments_007') }}
group by user_id
