with a as (select * from {{ ref('stg_support_tickets_018') }}),
b as (select * from {{ ref('int_model_0907') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
