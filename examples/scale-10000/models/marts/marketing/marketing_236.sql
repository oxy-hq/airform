with a as (select * from {{ ref('stg_support_tickets_036') }}),
b as (select * from {{ ref('int_model_0927') }})
select a.* from a inner join b on a.employee_id = b.employee_id
