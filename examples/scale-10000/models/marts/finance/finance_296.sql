with a as (select * from {{ ref('stg_events_096') }}),
b as (select * from {{ ref('int_model_0655') }})
select a.* from a inner join b on a.employee_id = b.employee_id
