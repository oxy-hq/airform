with a as (select * from {{ ref('stg_channels_018') }}),
b as (select * from {{ ref('int_model_1573') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
