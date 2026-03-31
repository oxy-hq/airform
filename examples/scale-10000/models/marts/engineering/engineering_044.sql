with a as (select * from {{ ref('stg_campaigns_044') }}),
b as (select * from {{ ref('int_model_1719') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
