with t1 as (select * from {{ ref('stg_order_items_052') }}),
t2 as (select * from {{ ref('int_model_1614') }}),
t3 as (select * from {{ ref('int_model_1629') }})
select t1.*
from t1
left join t2 on cast(t1.order_id as varchar) = cast(t2.order_id as varchar)
left join t3 on cast(t1.order_id as varchar) = cast(t3.order_id as varchar)
