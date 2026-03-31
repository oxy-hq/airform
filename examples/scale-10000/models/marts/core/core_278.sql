with a as (select * from {{ ref('stg_subscriptions_078') }}),
b as (select * from {{ ref('int_model_0306') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
