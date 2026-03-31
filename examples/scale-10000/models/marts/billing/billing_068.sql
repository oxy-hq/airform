with a as (select * from {{ ref('stg_events_068') }}),
b as (select * from {{ ref('int_model_1072') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
