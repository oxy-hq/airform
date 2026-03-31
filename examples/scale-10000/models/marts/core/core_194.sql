with a as (select * from {{ ref('stg_accounts_094') }}),
b as (select * from {{ ref('int_model_0215') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
