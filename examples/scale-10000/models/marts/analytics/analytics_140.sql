with a as (select * from {{ ref('stg_events_040') }}),
b as (select * from {{ ref('int_model_0819') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
