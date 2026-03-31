with a as (select * from {{ ref('stg_employees_038') }}),
b as (select * from {{ ref('int_model_1713') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
