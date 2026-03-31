select product_name, count(*) as total
from {{ ref('stg_page_views_031') }}
group by product_name
