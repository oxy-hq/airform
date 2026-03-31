with a as (select * from {{ ref('stg_shipments_034') }}),
b as (select * from {{ ref('int_model_0475') }})
select a.* from a inner join b on a.campaign_id = b.campaign_id
