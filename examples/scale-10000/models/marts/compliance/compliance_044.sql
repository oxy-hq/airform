with a as (select * from {{ ref('stg_page_views_044') }}),
b as (select * from {{ ref('int_model_1046') }})
select a.* from a inner join b on a.invoice_id = b.invoice_id
