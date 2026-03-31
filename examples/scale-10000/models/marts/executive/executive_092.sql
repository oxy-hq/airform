with a as (select * from {{ ref('stg_subscriptions_092') }}),
b as (select * from {{ ref('int_model_0766') }})
select a.* from a inner join b on a.order_id = b.order_id
