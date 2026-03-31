with a as (
    select * from {{ ref('stg_warehouses_02') }}
),

b as (
    select * from {{ ref('int_model_038') }}
)

select
    a.*,
    b.*
from a
inner join b on a.order_id = b.order_id
