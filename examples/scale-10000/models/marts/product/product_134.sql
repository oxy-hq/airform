with a as (select * from {{ ref('stg_products_034') }}),
b as (select * from {{ ref('int_model_1148') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
