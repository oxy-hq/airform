with a as (select * from {{ ref('stg_orders_098') }}),
b as (select * from {{ ref('int_model_1777') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
