select *, row_number() over (partition by product_name order by product_id) as rn
from {{ ref('stg_departments_071') }}
