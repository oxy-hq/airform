with a as (select * from {{ ref('stg_users_042') }}),
b as (select * from {{ ref('int_model_0267') }})
select a.* from a inner join b on a.account_id = b.account_id
