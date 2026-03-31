select department_name, count(*) as total
from {{ ref('stg_page_views_037') }}
group by department_name
