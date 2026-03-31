select order_id, count(*) as total
from {{ ref('stg_employees_053') }}
group by order_id
