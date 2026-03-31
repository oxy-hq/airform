with a as (select * from {{ ref('stg_events_076') }}),
b as (select * from {{ ref('int_model_0860') }})
select a.* from a inner join b on a.employee_id = b.employee_id
