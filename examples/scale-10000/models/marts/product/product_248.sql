with a as (select * from {{ ref('stg_orders_048') }}),
b as (select * from {{ ref('int_model_1275') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
