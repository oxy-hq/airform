with t1 as (select * from {{ ref('stg_sessions_036') }}),
t2 as (select * from {{ ref('int_model_0705') }}),
t3 as (select * from {{ ref('int_model_0718') }})
select t1.*
from t1
left join t2 on cast(t1.employee_id as varchar) = cast(t2.employee_id as varchar)
left join t3 on cast(t1.employee_id as varchar) = cast(t3.employee_id as varchar)
