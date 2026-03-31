with a as (select * from {{ ref('stg_order_items_092') }}),
b as (select * from {{ ref('int_model_1429') }})
select a.* from a inner join b on a.order_id = b.order_id
