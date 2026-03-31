with a as (select * from {{ ref('stg_payments_002') }}),
b as (select * from {{ ref('int_model_0663') }})
select a.* from a inner join b on a.account_id = b.account_id
