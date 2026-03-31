with t1 as (select * from {{ ref('stg_departments_092') }}),
t2 as (select * from {{ ref('int_model_1879') }}),
t3 as (select * from {{ ref('int_model_1893') }})
select t1.*
from t1
left join t2 on cast(t1.order_id as varchar) = cast(t2.order_id as varchar)
left join t3 on cast(t1.order_id as varchar) = cast(t3.order_id as varchar)
