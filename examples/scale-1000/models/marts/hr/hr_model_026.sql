with a as (
    select * from {{ ref('stg_order_items_06') }}
),

b as (
    select * from {{ ref('int_model_161') }}
)

select
    a.*,
    b.*
from a
inner join b on a.event_id = b.event_id
