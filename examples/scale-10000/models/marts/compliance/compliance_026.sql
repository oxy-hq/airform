with a as (select * from {{ ref('stg_page_views_026') }}),
b as (select * from {{ ref('int_model_1026') }})
select a.* from a inner join b on a.event_id = b.event_id
