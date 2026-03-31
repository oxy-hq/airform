with a as (select * from {{ ref('stg_users_008') }}),
b as (select * from {{ ref('int_model_0008') }})
select a.* from a inner join b on a.page_view_id = b.page_view_id
