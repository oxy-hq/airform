with a as (select * from {{ ref('stg_warehouses_030') }}),
b as (select * from {{ ref('int_model_1919') }})
select a.* from a inner join b on a.feature_usage_id = b.feature_usage_id
