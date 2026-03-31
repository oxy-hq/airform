with a as (select * from {{ ref('stg_campaigns_088') }}),
b as (select * from {{ ref('int_model_1540') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
