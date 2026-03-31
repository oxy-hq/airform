with t1 as (select * from {{ ref('stg_employees_088') }}),
t2 as (select * from {{ ref('int_model_1983') }}),
t3 as (select * from {{ ref('int_model_0001') }})
select t1.*
from t1
left join t2 on cast(t1.page_view_id as varchar) = cast(t2.page_view_id as varchar)
left join t3 on cast(t1.page_view_id as varchar) = cast(t3.page_view_id as varchar)
