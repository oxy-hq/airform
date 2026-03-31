with t1 as (select * from {{ ref('stg_departments_080') }}),
t2 as (select * from {{ ref('int_model_1866') }}),
t3 as (select * from {{ ref('int_model_1880') }})
select t1.*
from t1
left join t2 on cast(t1.compliance_record_id as varchar) = cast(t2.compliance_record_id as varchar)
left join t3 on cast(t1.compliance_record_id as varchar) = cast(t3.compliance_record_id as varchar)
