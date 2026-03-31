select user_id, count(*) as total
from {{ ref('stg_employees_069') }}
group by user_id
