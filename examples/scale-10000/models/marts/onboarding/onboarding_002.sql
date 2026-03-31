with a as (select * from {{ ref('stg_orders_002') }}),
b as (select * from {{ ref('int_model_1671') }})
select a.* from a inner join b on a.account_id = b.account_id
