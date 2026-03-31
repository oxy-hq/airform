with t1 as (select * from {{ ref('stg_users_064') }}),
t2 as (select * from {{ ref('int_model_0292') }}),
t3 as (select * from {{ ref('int_model_0305') }})
select t1.*
from t1
left join t2 on cast(t1.invoice_id as varchar) = cast(t2.invoice_id as varchar)
left join t3 on cast(t1.invoice_id as varchar) = cast(t3.invoice_id as varchar)
