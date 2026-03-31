with a as (select * from {{ ref('stg_shipments_088') }}),
b as (select * from {{ ref('int_model_0536') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
