with a as (
    select * from {{ ref('stg_events_04') }}
),

b as (
    select * from {{ ref('int_model_085') }}
)

select
    a.*,
    b.*
from a
inner join b on a.campaign_id = b.campaign_id
