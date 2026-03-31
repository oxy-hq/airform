with a as (select * from {{ ref('stg_support_tickets_100') }}),
b as (select * from {{ ref('int_model_1224') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
