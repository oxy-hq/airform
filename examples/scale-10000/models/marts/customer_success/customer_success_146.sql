with a as (select * from {{ ref('stg_orders_046') }}),
b as (select * from {{ ref('int_model_1491') }})
select a.* from a inner join b on a.event_id = b.event_id
