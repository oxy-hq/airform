with a as (select * from {{ ref('stg_orders_064') }}),
b as (select * from {{ ref('int_model_1511') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
