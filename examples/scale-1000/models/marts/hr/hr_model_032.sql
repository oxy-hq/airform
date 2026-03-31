with a as (
    select * from {{ ref('stg_campaigns_02') }}
),

b as (
    select * from {{ ref('int_model_167') }}
)

select
    a.*,
    b.*
from a
inner join b on a.order_id = b.order_id
