with a as (select * from {{ ref('stg_accounts_030') }}),
b as (select * from {{ ref('int_model_0582') }})
select a.* from a inner join b on a.feature_usage_id = b.feature_usage_id
