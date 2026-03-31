with a as (select * from {{ ref('stg_page_views_062') }}),
b as (select * from {{ ref('int_model_1066') }})
select a.* from a inner join b on a.account_id = b.account_id
