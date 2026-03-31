with a as (select * from {{ ref('stg_products_002') }}),
b as (select * from {{ ref('int_model_1333') }})
select a.* from a inner join b on a.account_id = b.account_id
