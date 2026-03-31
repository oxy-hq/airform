with a as (select * from {{ ref('stg_feature_usage_022') }}),
b as (select * from {{ ref('int_model_1464') }})
select a.* from a inner join b on a.account_id = b.account_id
