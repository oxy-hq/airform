with t1 as (select * from {{ ref('stg_employees_002') }}),
t2 as (select * from {{ ref('int_model_0111') }}),
t3 as (select * from {{ ref('int_model_0128') }})
select t1.*
from t1
left join t2 on cast(t1.account_id as varchar) = cast(t2.account_id as varchar)
left join t3 on cast(t1.account_id as varchar) = cast(t3.account_id as varchar)
