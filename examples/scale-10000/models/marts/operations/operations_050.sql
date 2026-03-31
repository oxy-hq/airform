with a as (select * from {{ ref('stg_order_items_050') }}),
b as (select * from {{ ref('int_model_1384') }})
select a.* from a inner join b on a.feature_usage_id = b.feature_usage_id
