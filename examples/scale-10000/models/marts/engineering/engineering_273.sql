select order_id, count(*) as total
from {{ ref('stg_employees_073') }}
group by order_id
