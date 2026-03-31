with a as (select * from {{ ref('stg_orders_084') }}),
b as (select * from {{ ref('int_model_1313') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
