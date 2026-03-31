with a as (
    select * from {{ ref('stg_order_items_08') }}
),

b as (
    select * from {{ ref('int_model_143') }}
)

select
    a.*,
    b.*
from a
inner join b on a.page_view_id = b.page_view_id
