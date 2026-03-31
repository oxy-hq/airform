select department_name, count(*) as total
from {{ ref('stg_order_items_077') }}
group by department_name
