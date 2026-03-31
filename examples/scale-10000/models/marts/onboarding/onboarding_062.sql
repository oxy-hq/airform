with a as (select * from {{ ref('stg_orders_062') }}),
b as (select * from {{ ref('int_model_1738') }})
select a.* from a inner join b on a.account_id = b.account_id
