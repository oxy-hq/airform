with a as (select * from {{ ref('stg_campaigns_052') }}),
b as (select * from {{ ref('int_model_1497') }})
select a.* from a inner join b on a.order_id = b.order_id
