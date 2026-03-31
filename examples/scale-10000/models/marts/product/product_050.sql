with a as (select * from {{ ref('stg_feature_usage_050') }}),
b as (select * from {{ ref('int_model_1054') }})
select a.* from a inner join b on a.feature_usage_id = b.feature_usage_id
