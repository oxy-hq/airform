with a as (select * from {{ ref('stg_order_items_054') }}),
b as (select * from {{ ref('int_model_1616') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
