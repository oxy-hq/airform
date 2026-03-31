with t1 as (select * from {{ ref('stg_compliance_records_032') }}),
t2 as (select * from {{ ref('int_model_0147') }}),
t3 as (select * from {{ ref('int_model_0163') }})
select t1.*
from t1
left join t2 on cast(t1.order_id as varchar) = cast(t2.order_id as varchar)
left join t3 on cast(t1.order_id as varchar) = cast(t3.order_id as varchar)
