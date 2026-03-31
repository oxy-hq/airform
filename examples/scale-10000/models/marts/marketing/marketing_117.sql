select department_name, count(*) as total
from {{ ref('stg_page_views_017') }}
group by department_name
