with t1 as (select * from {{ ref('stg_page_views_066') }}),
t2 as (select * from {{ ref('int_model_1070') }}),
t3 as (select * from {{ ref('int_model_1084') }})
select t1.*
from t1
left join t2 on cast(t1.event_id as varchar) = cast(t2.event_id as varchar)
left join t3 on cast(t1.event_id as varchar) = cast(t3.event_id as varchar)
