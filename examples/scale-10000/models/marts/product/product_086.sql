with a as (select * from {{ ref('stg_feature_usage_086') }}),
b as (select * from {{ ref('int_model_1093') }})
select a.* from a inner join b on a.event_id = b.event_id
