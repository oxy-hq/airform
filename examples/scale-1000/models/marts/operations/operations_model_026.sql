with a as (
    select * from {{ ref('stg_sessions_06') }}
),

b as (
    select * from {{ ref('int_model_098') }}
)

select
    a.*,
    b.*
from a
inner join b on a.event_id = b.event_id
