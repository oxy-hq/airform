with a as (select * from {{ ref('stg_subscriptions_058') }}),
b as (select * from {{ ref('int_model_0500') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
