with a as (select * from {{ ref('stg_events_078') }}),
b as (select * from {{ ref('int_model_0635') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
