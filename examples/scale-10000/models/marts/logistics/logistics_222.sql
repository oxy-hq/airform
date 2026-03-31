with t1 as (select * from {{ ref('stg_invoices_022') }}),
t2 as (select * from {{ ref('int_model_0572') }}),
t3 as (select * from {{ ref('int_model_0588') }})
select t1.*
from t1
left join t2 on cast(t1.account_id as varchar) = cast(t2.account_id as varchar)
left join t3 on cast(t1.account_id as varchar) = cast(t3.account_id as varchar)
