with t1 as (select * from {{ ref('stg_events_078') }}),
t2 as (select * from {{ ref('int_model_1082') }}),
t3 as (select * from {{ ref('int_model_1098') }})
select t1.*
from t1
left join t2 on cast(t1.warehouse_id as varchar) = cast(t2.warehouse_id as varchar)
left join t3 on cast(t1.warehouse_id as varchar) = cast(t3.warehouse_id as varchar)
