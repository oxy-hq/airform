with a as (select * from {{ ref('stg_feature_usage_076') }}),
b as (select * from {{ ref('int_model_1524') }})
select a.* from a inner join b on a.employee_id = b.employee_id
