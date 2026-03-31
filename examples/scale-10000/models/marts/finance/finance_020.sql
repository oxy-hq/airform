with a as (select * from {{ ref('stg_invoices_020') }}),
b as (select * from {{ ref('int_model_0352') }})
select a.* from a inner join b on a.compliance_record_id = b.compliance_record_id
