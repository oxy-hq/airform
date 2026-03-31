select department_name, count(*) as total
from {{ ref('stg_page_views_097') }}
group by department_name
