with a as (select * from {{ ref('stg_campaigns_092') }}),
b as (select * from {{ ref('int_model_1771') }})
select a.* from a inner join b on a.order_id = b.order_id
