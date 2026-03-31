with a as (select * from {{ ref('stg_sessions_060') }}),
b as (select * from {{ ref('int_model_0953') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
