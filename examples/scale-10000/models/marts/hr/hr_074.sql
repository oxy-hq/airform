with a as (select * from {{ ref('stg_employees_074') }}),
b as (select * from {{ ref('int_model_1752') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
