with a as (select * from {{ ref('stg_order_items_056') }}),
b as (select * from {{ ref('int_model_1391') }})
select a.* from a inner join b on a.employee_id = b.employee_id
