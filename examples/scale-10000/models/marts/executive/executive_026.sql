with a as (select * from {{ ref('stg_subscriptions_026') }}),
b as (select * from {{ ref('int_model_0694') }})
select a.* from a inner join b on a.event_id = b.event_id
