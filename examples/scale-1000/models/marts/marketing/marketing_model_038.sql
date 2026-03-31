with a as (
    select * from {{ ref('stg_employees_08') }}
),

b as (
    select * from {{ ref('int_model_174') }}
)

select
    a.*,
    b.*
from a
inner join b on a.warehouse_id = b.warehouse_id
