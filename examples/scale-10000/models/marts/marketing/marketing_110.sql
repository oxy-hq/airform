with a as (select * from {{ ref('stg_page_views_010') }}),
b as (select * from {{ ref('int_model_0786') }})
select a.* from a inner join b on a.feature_usage_id = b.feature_usage_id
