with a as (select * from {{ ref('stg_subscriptions_066') }}),
b as (select * from {{ ref('int_model_0294') }})
select a.* from a inner join b on a.event_id = b.event_id
