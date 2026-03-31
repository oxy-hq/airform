with a as (select * from {{ ref('stg_products_012') }}),
b as (select * from {{ ref('int_model_1566') }})
select a.* from a inner join b on a.order_id = b.order_id
