with a as (select * from {{ ref('stg_departments_062') }}),
b as (select * from {{ ref('int_model_0069') }})
select a.* from a inner join b on a.account_id = b.account_id
