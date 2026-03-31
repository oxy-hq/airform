with a as (select * from {{ ref('stg_invoices_014') }}),
b as (select * from {{ ref('int_model_0346') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
