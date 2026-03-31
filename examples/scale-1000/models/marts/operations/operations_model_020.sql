with a as (
    select * from {{ ref('stg_events_10') }}
),

b as (
    select * from {{ ref('int_model_091') }}
)

select
    a.*,
    b.*
from a
inner join b on a.compliance_record_id = b.compliance_record_id
