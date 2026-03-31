with a as (select * from {{ ref('stg_compliance_records_026') }}),
b as (select * from {{ ref('int_model_0358') }})
select a.* from a inner join b on a.event_id = b.event_id
