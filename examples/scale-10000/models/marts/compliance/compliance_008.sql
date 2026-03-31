with a as (select * from {{ ref('stg_page_views_008') }}),
b as (select * from {{ ref('int_model_1007') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
