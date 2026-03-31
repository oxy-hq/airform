with a as (select * from {{ ref('stg_departments_064') }}),
b as (select * from {{ ref('int_model_1848') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
