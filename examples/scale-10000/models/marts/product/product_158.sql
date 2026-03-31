with a as (select * from {{ ref('stg_products_058') }}),
b as (select * from {{ ref('int_model_1179') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
