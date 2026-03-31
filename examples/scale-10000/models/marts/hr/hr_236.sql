with a as (select * from {{ ref('stg_warehouses_036') }}),
b as (select * from {{ ref('int_model_1925') }})
select a.* from a inner join b on a.employee_id = b.employee_id
