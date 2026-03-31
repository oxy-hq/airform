with a as (select * from {{ ref('stg_compliance_records_036') }}),
b as (select * from {{ ref('int_model_0589') }})
select a.* from a inner join b on a.employee_id = b.employee_id
