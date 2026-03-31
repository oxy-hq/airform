with a as (select * from {{ ref('stg_employees_068') }}),
b as (select * from {{ ref('int_model_1745') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
