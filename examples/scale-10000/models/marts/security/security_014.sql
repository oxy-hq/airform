with a as (select * from {{ ref('stg_departments_014') }}),
b as (select * from {{ ref('int_model_0015') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
