with a as (select * from {{ ref('stg_subscriptions_046') }}),
b as (select * from {{ ref('int_model_0487') }})
select a.* from a inner join b on a.event_id = b.event_id
