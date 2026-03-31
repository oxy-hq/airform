with t1 as (select * from {{ ref('stg_invoices_016') }}),
t2 as (select * from {{ ref('int_model_0565') }}),
t3 as (select * from {{ ref('int_model_0581') }})
select t1.*
from t1
left join t2 on cast(t1.employee_id as varchar) = cast(t2.employee_id as varchar)
left join t3 on cast(t1.employee_id as varchar) = cast(t3.employee_id as varchar)
