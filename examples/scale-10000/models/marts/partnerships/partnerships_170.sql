with a as (select * from {{ ref('stg_feature_usage_070') }}),
b as (select * from {{ ref('int_model_1518') }})
select a.* from a inner join b on a.feature_usage_id = b.feature_usage_id
