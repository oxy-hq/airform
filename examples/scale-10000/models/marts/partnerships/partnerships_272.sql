with a as (select * from {{ ref('stg_products_072') }}),
b as (select * from {{ ref('int_model_1639') }})
select a.* from a inner join b on a.order_id = b.order_id
