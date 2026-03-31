with a as (select * from {{ ref('stg_orders_054') }}),
b as (select * from {{ ref('int_model_1281') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
