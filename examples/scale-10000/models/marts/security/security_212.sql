with a as (select * from {{ ref('stg_shipments_012') }}),
b as (select * from {{ ref('int_model_0236') }})
select a.* from a inner join b on a.order_id = b.order_id
