with a as (select * from {{ ref('stg_invoices_004') }}),
b as (select * from {{ ref('int_model_0779') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
