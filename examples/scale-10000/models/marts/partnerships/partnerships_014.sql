with a as (select * from {{ ref('stg_support_tickets_014') }}),
b as (select * from {{ ref('int_model_1345') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
