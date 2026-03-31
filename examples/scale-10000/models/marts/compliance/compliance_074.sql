with a as (select * from {{ ref('stg_page_views_074') }}),
b as (select * from {{ ref('int_model_1078') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
