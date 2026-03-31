with a as (select * from {{ ref('stg_compliance_records_044') }}),
b as (select * from {{ ref('int_model_0376') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
