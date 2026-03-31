with a as (select * from {{ ref('stg_payments_044') }}),
b as (select * from {{ ref('int_model_0713') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
