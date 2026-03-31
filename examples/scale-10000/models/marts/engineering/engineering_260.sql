with a as (select * from {{ ref('stg_employees_060') }}),
b as (select * from {{ ref('int_model_1953') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
