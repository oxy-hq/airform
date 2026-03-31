with a as (select * from {{ ref('stg_order_items_058') }}),
b as (select * from {{ ref('int_model_1842') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
