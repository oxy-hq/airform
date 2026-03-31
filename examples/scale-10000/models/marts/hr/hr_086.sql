with a as (select * from {{ ref('stg_employees_086') }}),
b as (select * from {{ ref('int_model_1765') }})
select a.* from a inner join b on a.event_id = b.event_id
