with a as (select * from {{ ref('stg_channels_100') }}),
b as (select * from {{ ref('int_model_1887') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
