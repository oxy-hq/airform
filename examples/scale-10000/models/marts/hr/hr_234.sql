with t1 as (select * from {{ ref('stg_warehouses_034') }}),
t2 as (select * from {{ ref('int_model_1923') }}),
t3 as (select * from {{ ref('int_model_1938') }})
select t1.*
from t1
left join t2 on cast(t1.campaign_id as varchar) = cast(t2.campaign_id as varchar)
left join t3 on cast(t1.campaign_id as varchar) = cast(t3.campaign_id as varchar)
