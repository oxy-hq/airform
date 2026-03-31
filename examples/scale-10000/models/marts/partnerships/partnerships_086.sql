with a as (select * from {{ ref('stg_support_tickets_086') }}),
b as (select * from {{ ref('int_model_1423') }})
select a.* from a inner join b on a.event_id = b.event_id
