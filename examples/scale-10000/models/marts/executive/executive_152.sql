with a as (select * from {{ ref('stg_invoices_052') }}),
b as (select * from {{ ref('int_model_0832') }})
select a.* from a inner join b on a.order_id = b.order_id
