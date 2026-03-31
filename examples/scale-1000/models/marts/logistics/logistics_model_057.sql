select
    department_name,
    count(*) as total_records,
    sum(1) as sum_val
from {{ ref('stg_page_views_07') }}
group by department_name
