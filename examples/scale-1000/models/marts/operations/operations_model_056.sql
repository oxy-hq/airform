with a as (
    select * from {{ ref('stg_feature_usage_06') }}
),

b as (
    select * from {{ ref('int_model_130') }}
)

select
    a.*,
    b.*
from a
inner join b on a.employee_id = b.employee_id
