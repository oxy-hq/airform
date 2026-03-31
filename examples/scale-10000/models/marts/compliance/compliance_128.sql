with a as (select * from {{ ref('stg_support_tickets_028') }}),
b as (select * from {{ ref('int_model_1138') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
