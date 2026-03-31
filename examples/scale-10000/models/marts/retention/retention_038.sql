with a as (select * from {{ ref('stg_channels_038') }}),
b as (select * from {{ ref('int_model_0041') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
