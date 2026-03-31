with a as (select * from {{ ref('stg_sessions_096') }}),
b as (select * from {{ ref('int_model_0993') }})
select a.* from a inner join b on a.employee_id = b.employee_id
