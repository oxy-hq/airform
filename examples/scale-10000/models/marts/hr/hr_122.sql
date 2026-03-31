with a as (select * from {{ ref('stg_departments_022') }}),
b as (select * from {{ ref('int_model_1805') }})
select a.* from a inner join b on a.account_id = b.account_id
