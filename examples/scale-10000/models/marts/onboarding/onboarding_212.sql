with a as (select * from {{ ref('stg_campaigns_012') }}),
b as (select * from {{ ref('int_model_1900') }})
select a.* from a inner join b on a.order_id = b.order_id
