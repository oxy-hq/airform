with a as (select * from {{ ref('stg_products_046') }}),
b as (select * from {{ ref('int_model_1164') }})
select a.* from a inner join b on a.event_id = b.event_id
