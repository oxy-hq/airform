with t1 as (select * from {{ ref('stg_warehouses_010') }}),
t2 as (select * from {{ ref('int_model_1898') }}),
t3 as (select * from {{ ref('int_model_1912') }})
select t1.*
from t1
left join t2 on cast(t1.feature_usage_id as varchar) = cast(t2.feature_usage_id as varchar)
left join t3 on cast(t1.feature_usage_id as varchar) = cast(t3.feature_usage_id as varchar)
