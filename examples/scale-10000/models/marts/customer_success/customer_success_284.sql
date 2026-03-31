with a as (select * from {{ ref('stg_order_items_084') }}),
b as (select * from {{ ref('int_model_1653') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
