select order_id, count(*) as total
from {{ ref('stg_departments_093') }}
group by order_id
