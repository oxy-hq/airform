with a as (select * from {{ ref('stg_page_views_042') }}),
b as (select * from {{ ref('int_model_1269') }})
select a.* from a inner join b on a.account_id = b.account_id
