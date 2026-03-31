with a as (select * from {{ ref('stg_channels_092') }}),
b as (select * from {{ ref('int_model_0101') }})
select a.* from a inner join b on a.order_id = b.order_id
