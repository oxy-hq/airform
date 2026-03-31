with a as (select * from {{ ref('stg_payments_066') }}),
b as (select * from {{ ref('int_model_0959') }})
select a.* from a inner join b on a.event_id = b.event_id
