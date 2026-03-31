with a as (
    select * from {{ ref('stg_sessions_10') }}
),

b as (
    select * from {{ ref('int_model_123') }}
)

select
    a.*,
    b.*
from a
inner join b on a.feature_usage_id = b.feature_usage_id
