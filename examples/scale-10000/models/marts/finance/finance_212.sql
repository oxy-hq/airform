with a as (select * from {{ ref('stg_events_012') }}),
b as (select * from {{ ref('int_model_0560') }})
select a.* from a inner join b on a.order_id = b.order_id
