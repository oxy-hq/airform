select order_id, count(*) as total
from {{ ref('stg_departments_059') }}
group by order_id
