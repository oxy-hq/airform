with t1 as (select * from {{ ref('stg_support_tickets_082') }}),
t2 as (select * from {{ ref('int_model_0978') }}),
t3 as (select * from {{ ref('int_model_0992') }})
select t1.*
from t1
left join t2 on cast(t1.account_id as varchar) = cast(t2.account_id as varchar)
left join t3 on cast(t1.account_id as varchar) = cast(t3.account_id as varchar)
