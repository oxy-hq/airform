with a as (select * from {{ ref('stg_shipments_056') }}),
b as (select * from {{ ref('int_model_0062') }})
select a.* from a inner join b on a.employee_id = b.employee_id
