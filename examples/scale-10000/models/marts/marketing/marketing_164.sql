with a as (select * from {{ ref('stg_page_views_064') }}),
b as (select * from {{ ref('int_model_0846') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
