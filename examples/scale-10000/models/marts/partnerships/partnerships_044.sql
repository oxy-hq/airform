with a as (select * from {{ ref('stg_support_tickets_044') }}),
b as (select * from {{ ref('int_model_1378') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
