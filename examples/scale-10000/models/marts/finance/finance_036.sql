with t1 as (select * from {{ ref('stg_invoices_036') }}),
t2 as (select * from {{ ref('int_model_0368') }}),
t3 as (select * from {{ ref('int_model_0382') }})
select t1.*
from t1
left join t2 on cast(t1.employee_id as varchar) = cast(t2.employee_id as varchar)
left join t3 on cast(t1.employee_id as varchar) = cast(t3.employee_id as varchar)
