with t1 as (
    select * from {{ ref('stg_payments_10') }}
),

t2 as (
    select * from {{ ref('int_model_102') }}
),

t3 as (
    select * from {{ ref('int_model_116') }}
)

select
    t1.*
from t1
left join t2 on cast(t1.feature_usage_id as varchar) = cast(t2.feature_usage_id as varchar)
left join t3 on cast(t1.feature_usage_id as varchar) = cast(t3.feature_usage_id as varchar)
