with t1 as (select * from {{ ref('stg_shipments_046') }}),
t2 as (select * from {{ ref('int_model_0271') }}),
t3 as (select * from {{ ref('int_model_0285') }})
select t1.*
from t1
left join t2 on cast(t1.event_id as varchar) = cast(t2.event_id as varchar)
left join t3 on cast(t1.event_id as varchar) = cast(t3.event_id as varchar)
