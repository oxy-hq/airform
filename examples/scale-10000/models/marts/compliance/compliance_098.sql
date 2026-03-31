with a as (select * from {{ ref('stg_page_views_098') }}),
b as (select * from {{ ref('int_model_1107') }})
select a.* from a inner join b on a.warehouse_id = b.warehouse_id
