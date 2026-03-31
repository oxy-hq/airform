with a as (select * from {{ ref('stg_products_036') }}),
b as (select * from {{ ref('int_model_1595') }})
select a.* from a inner join b on a.employee_id = b.employee_id
