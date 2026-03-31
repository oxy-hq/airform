with a as (select * from {{ ref('stg_order_items_066') }}),
b as (select * from {{ ref('int_model_1630') }})
select a.* from a inner join b on a.event_id = b.event_id
