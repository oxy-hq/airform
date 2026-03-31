with a as (select * from {{ ref('stg_products_010') }}),
b as (select * from {{ ref('int_model_1119') }})
select a.* from a inner join b on a.feature_usage_id = b.feature_usage_id
