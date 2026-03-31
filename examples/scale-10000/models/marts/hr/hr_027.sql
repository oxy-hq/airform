select user_id, count(*) as total
from {{ ref('stg_employees_027') }}
group by user_id
