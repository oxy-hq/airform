with a as (select * from {{ ref('stg_events_032') }}),
b as (select * from {{ ref('int_model_1034') }})
select a.* from a inner join b on a.order_id = b.order_id
