with t1 as (select * from {{ ref('stg_warehouses_060') }}),
t2 as (select * from {{ ref('int_model_0393') }}),
t3 as (select * from {{ ref('int_model_0406') }})
select t1.*
from t1
left join t2 on cast(t1.compliance_record_id as varchar) = cast(t2.compliance_record_id as varchar)
left join t3 on cast(t1.compliance_record_id as varchar) = cast(t3.compliance_record_id as varchar)
