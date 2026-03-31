with a as (select * from {{ ref('stg_products_042') }}),
b as (select * from {{ ref('int_model_1603') }})
select a.* from a inner join b on a.account_id = b.account_id
