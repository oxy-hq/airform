with a as (select * from {{ ref('stg_compliance_records_086') }}),
b as (select * from {{ ref('int_model_0423') }})
select a.* from a inner join b on a.event_id = b.event_id
