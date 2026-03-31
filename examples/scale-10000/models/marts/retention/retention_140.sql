with a as (select * from {{ ref('stg_employees_040') }}),
b as (select * from {{ ref('int_model_0158') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
