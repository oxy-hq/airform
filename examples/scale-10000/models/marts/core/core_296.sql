with a as (select * from {{ ref('stg_subscriptions_096') }}),
b as (select * from {{ ref('int_model_0327') }})
select a.* from a inner join b on a.employee_id = b.employee_id
