with a as (select * from {{ ref('stg_support_tickets_068') }}),
b as (select * from {{ ref('int_model_1403') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
