with a as (select * from {{ ref('stg_orders_072') }}),
b as (select * from {{ ref('int_model_1299') }})
select a.* from a inner join b on a.order_id = b.order_id
