with a as (select * from {{ ref('stg_payments_074') }}),
b as (select * from {{ ref('int_model_0746') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
