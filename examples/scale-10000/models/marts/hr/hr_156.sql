with t1 as (select * from {{ ref('stg_departments_056') }}),
t2 as (select * from {{ ref('int_model_1840') }}),
t3 as (select * from {{ ref('int_model_1853') }})
select t1.*
from t1
left join t2 on cast(t1.employee_id as varchar) = cast(t2.employee_id as varchar)
left join t3 on cast(t1.employee_id as varchar) = cast(t3.employee_id as varchar)
