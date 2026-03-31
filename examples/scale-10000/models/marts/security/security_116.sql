with a as (select * from {{ ref('stg_warehouses_016') }}),
b as (select * from {{ ref('int_model_0129') }})
select a.* from a inner join b on a.employee_id = b.employee_id
