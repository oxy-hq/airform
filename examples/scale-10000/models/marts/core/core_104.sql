with a as (select * from {{ ref('stg_accounts_004') }}),
b as (select * from {{ ref('int_model_0113') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
