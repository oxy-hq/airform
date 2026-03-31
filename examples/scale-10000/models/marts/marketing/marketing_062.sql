with a as (select * from {{ ref('stg_sessions_062') }}),
b as (select * from {{ ref('int_model_0732') }})
select a.* from a inner join b on a.account_id = b.account_id
