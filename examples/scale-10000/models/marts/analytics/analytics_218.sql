with a as (select * from {{ ref('stg_sessions_018') }}),
b as (select * from {{ ref('int_model_0907') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
