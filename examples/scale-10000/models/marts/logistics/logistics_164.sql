with a as (select * from {{ ref('stg_subscriptions_064') }}),
b as (select * from {{ ref('int_model_0507') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
