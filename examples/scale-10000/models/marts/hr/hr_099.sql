select order_id, count(*) as total
from {{ ref('stg_employees_099') }}
group by order_id
