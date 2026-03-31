with a as (select * from {{ ref('stg_departments_074') }}),
b as (select * from {{ ref('int_model_0081') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
