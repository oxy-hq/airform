with a as (
    select * from {{ ref('stg_channels_08') }}
),

b as (
    select * from {{ ref('int_model_009') }}
)

select
    a.*,
    b.*
from a
inner join b on a.page_view_id = b.page_view_id
